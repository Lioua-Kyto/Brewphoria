import request from "supertest";
import app from "../app";
import { prisma } from "../config/database";
import { firebaseAuth } from "../config/firebase";
import { jest } from "@jest/globals";

jest.mock("../config/firebase", () => ({
  firebaseAuth: { verifyIdToken: jest.fn() },
  firebaseMessaging: { send: jest.fn().mockResolvedValue("msg-id" as never) },
  firebaseApp: {},
}));

const mockFirebaseAuth = firebaseAuth as jest.Mocked<typeof firebaseAuth>;

const USER_UID = "users-test-uid";
const USER_EMAIL = "users-test@brewphoria.com";

function mockAuth(uid = USER_UID, email = USER_EMAIL) {
  (
    mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
      typeof mockFirebaseAuth.verifyIdToken
    >
  ).mockResolvedValueOnce({ uid, email, name: "Users Test" } as never);
}

describe("User Routes", () => {
  let userId: string;

  beforeAll(async () => {
    const user = await prisma.user.upsert({
      where: { firebaseUid: USER_UID },
      create: {
        firebaseUid: USER_UID,
        email: USER_EMAIL,
        displayName: "Users Test",
        loyaltyAccount: {
          create: { currentPoints: 0, lifetimePoints: 0, tier: "BRONZE" },
        },
      },
      update: {},
    });
    userId = user.id;
  });

  afterAll(async () => {
    await prisma.address.deleteMany({ where: { userId } });
    await prisma.loyaltyAccount.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { id: userId } });
    jest.clearAllMocks();
  });

  afterEach(() => jest.clearAllMocks());

  // ── GET /api/v1/users/me ─────────────────────────────────────────────────────
  describe("GET /api/v1/users/me", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app).get("/api/v1/users/me");
      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });

    it("should return the current user's profile", async () => {
      mockAuth();
      const res = await request(app)
        .get("/api/v1/users/me")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.email).toBe(USER_EMAIL);
      expect(res.body.data.displayName).toBe("Users Test");
    });
  });

  // ── PATCH /api/v1/users/me ───────────────────────────────────────────────────
  describe("PATCH /api/v1/users/me", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app)
        .patch("/api/v1/users/me")
        .send({ displayName: "New Name" });
      expect(res.status).toBe(401);
    });

    it("should update the user's display name", async () => {
      mockAuth();
      const res = await request(app)
        .patch("/api/v1/users/me")
        .set("Authorization", "Bearer token")
        .send({ displayName: "Updated Name" });
      expect(res.status).toBe(200);
      expect(res.body.data.displayName).toBe("Updated Name");
    });

    it("should return 400 for an invalid avatarUrl", async () => {
      mockAuth();
      const res = await request(app)
        .patch("/api/v1/users/me")
        .set("Authorization", "Bearer token")
        .send({ avatarUrl: "not-a-url" });
      expect(res.status).toBe(400);
    });

    it("should accept an empty body without error", async () => {
      mockAuth();
      const res = await request(app)
        .patch("/api/v1/users/me")
        .set("Authorization", "Bearer token")
        .send({});
      expect(res.status).toBe(200);
    });
  });

  // ── GET /api/v1/users/me/addresses ──────────────────────────────────────────
  describe("GET /api/v1/users/me/addresses", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app).get("/api/v1/users/me/addresses");
      expect(res.status).toBe(401);
    });

    it("should return an empty array initially", async () => {
      mockAuth();
      const res = await request(app)
        .get("/api/v1/users/me/addresses")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // ── POST /api/v1/users/me/addresses ─────────────────────────────────────────
  describe("POST /api/v1/users/me/addresses", () => {
    const validAddress = {
      label: "Home",
      fullName: "Test User",
      phone: "5551234567",
      street: "123 Coffee Lane",
      city: "Portland",
      state: "OR",
      postalCode: "97201",
      country: "US",
    };

    let createdAddressId: string;

    it("should return 401 without auth", async () => {
      const res = await request(app)
        .post("/api/v1/users/me/addresses")
        .send(validAddress);
      expect(res.status).toBe(401);
    });

    it("should return 400 when required fields are missing", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/users/me/addresses")
        .set("Authorization", "Bearer token")
        .send({ label: "Home" }); // missing most fields
      expect(res.status).toBe(400);
    });

    it("should create a new address with valid data", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/users/me/addresses")
        .set("Authorization", "Bearer token")
        .send(validAddress);
      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.label).toBe("Home");
      expect(res.body.data.city).toBe("Portland");
      createdAddressId = res.body.data.id;
    });

    // ── PATCH /api/v1/users/me/addresses/:id ──────────────────────────────────
    describe("PATCH /api/v1/users/me/addresses/:id", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app)
          .patch(`/api/v1/users/me/addresses/some-id`)
          .send({ city: "Seattle" });
        expect(res.status).toBe(401);
      });

      it("should return 404 for a non-existent address", async () => {
        mockAuth();
        const res = await request(app)
          .patch("/api/v1/users/me/addresses/nonexistentid000000000000")
          .set("Authorization", "Bearer token")
          .send({ city: "Seattle" });
        expect(res.status).toBe(404);
      });

      it("should update an existing address", async () => {
        mockAuth();
        const res = await request(app)
          .patch(`/api/v1/users/me/addresses/${createdAddressId}`)
          .set("Authorization", "Bearer token")
          .send({ city: "Seattle", state: "WA" });
        expect(res.status).toBe(200);
        expect(res.body.data.city).toBe("Seattle");
      });
    });

    // ── DELETE /api/v1/users/me/addresses/:id ─────────────────────────────────
    describe("DELETE /api/v1/users/me/addresses/:id", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).delete(
          `/api/v1/users/me/addresses/some-id`,
        );
        expect(res.status).toBe(401);
      });

      it("should return 404 for a non-existent address", async () => {
        mockAuth();
        const res = await request(app)
          .delete("/api/v1/users/me/addresses/nonexistentid000000000000")
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(404);
      });

      it("should delete an existing address", async () => {
        mockAuth();
        const res = await request(app)
          .delete(`/api/v1/users/me/addresses/${createdAddressId}`)
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
      });
    });
  });
});
