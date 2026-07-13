import request from "supertest";
import app from "../app";
import { prisma } from "../config/database";
import { firebaseAuth } from "../config/firebase";
import { jest } from "@jest/globals";

// Mock Firebase auth
jest.mock("../config/firebase", () => ({
  firebaseAuth: {
    verifyIdToken: jest.fn(),
  },
  firebaseMessaging: {
    send: jest.fn().mockResolvedValue("message-id" as never),
  },
  firebaseApp: {},
}));

const mockFirebaseAuth = firebaseAuth as jest.Mocked<typeof firebaseAuth>;

describe("Auth Routes", () => {
  const testUser = {
    uid: "firebase-test-uid-auth",
    email: "auth-test@brewphoria.com",
    name: "Auth Test User",
    picture: undefined,
  };

  afterEach(async () => {
    await prisma.loyaltyAccount.deleteMany({
      where: { user: { email: testUser.email } },
    });
    await prisma.user.deleteMany({ where: { email: testUser.email } });
    jest.clearAllMocks();
  });

  describe("POST /api/v1/auth/login", () => {
    it("should login successfully and return user + loyalty summary", async () => {
      (
        mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
          typeof mockFirebaseAuth.verifyIdToken
        >
      ).mockResolvedValueOnce(
        testUser as unknown as Awaited<
          ReturnType<typeof mockFirebaseAuth.verifyIdToken>
        >,
      );

      const res = await request(app).post("/api/v1/auth/login").send({
        idToken: "valid-firebase-token",
      });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user.email).toBe(testUser.email);
      expect(res.body.data.loyaltySummary).toBeDefined();
      expect(res.body.data.loyaltySummary.tier).toBe("BRONZE");
    });

    it("should return 400 when idToken is missing", async () => {
      const res = await request(app).post("/api/v1/auth/login").send({});
      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it("should return 401 when Firebase token is invalid", async () => {
      (
        mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
          typeof mockFirebaseAuth.verifyIdToken
        >
      ).mockRejectedValueOnce(new Error("Invalid token"));

      const res = await request(app)
        .post("/api/v1/auth/login")
        .send({ idToken: "invalid-token" });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });
  });

  describe("POST /api/v1/auth/logout", () => {
    it("should return 401 when not authenticated", async () => {
      const res = await request(app).post("/api/v1/auth/logout");
      expect(res.status).toBe(401);
    });

    it("should logout successfully with valid token", async () => {
      // First create user
      (
        mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
          typeof mockFirebaseAuth.verifyIdToken
        >
      ).mockResolvedValueOnce(
        testUser as unknown as Awaited<
          ReturnType<typeof mockFirebaseAuth.verifyIdToken>
        >,
      );

      await request(app).post("/api/v1/auth/login").send({ idToken: "token" });

      // Setup auth mock for logout
      const user = await prisma.user.findUnique({
        where: { email: testUser.email },
      });
      (
        mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
          typeof mockFirebaseAuth.verifyIdToken
        >
      ).mockResolvedValueOnce(
        testUser as unknown as Awaited<
          ReturnType<typeof mockFirebaseAuth.verifyIdToken>
        >,
      );

      const res = await request(app)
        .post("/api/v1/auth/logout")
        .set("Authorization", "Bearer valid-token");

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);

      void user; // suppress unused variable warning
    });
  });

  describe("PATCH /api/v1/auth/fcm-token", () => {
    it("should return 401 when not authenticated", async () => {
      const res = await request(app).patch("/api/v1/auth/fcm-token");
      expect(res.status).toBe(401);
    });
  });
});
