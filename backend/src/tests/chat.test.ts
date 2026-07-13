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

jest.mock("@google/genai", () => ({
  GoogleGenAI: jest.fn().mockImplementation(() => ({
    models: {
      generateContent: jest.fn().mockResolvedValue({
        text: "I recommend our Classic Espresso — rich, bold, and perfect for a morning pick-me-up!",
      } as never),
    },
  })),
}));

const mockFirebaseAuth = firebaseAuth as jest.Mocked<typeof firebaseAuth>;

const USER_UID = "chat-test-uid";
const USER_EMAIL = "chat-test@brewphoria.com";

function mockAuth() {
  (
    mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
      typeof mockFirebaseAuth.verifyIdToken
    >
  ).mockResolvedValueOnce({
    uid: USER_UID,
    email: USER_EMAIL,
    name: "Chat Test",
  } as never);
}

describe("Chat Routes", () => {
  let userId: string;

  beforeAll(async () => {
    const user = await prisma.user.upsert({
      where: { firebaseUid: USER_UID },
      create: {
        firebaseUid: USER_UID,
        email: USER_EMAIL,
        displayName: "Chat Test",
        loyaltyAccount: {
          create: { currentPoints: 0, lifetimePoints: 0, tier: "BRONZE" },
        },
      },
      update: {},
    });
    userId = user.id;
  });

  afterAll(async () => {
    await prisma.chatMessage.deleteMany({ where: { session: { userId } } });
    await prisma.chatSession.deleteMany({ where: { userId } });
    await prisma.loyaltyAccount.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { id: userId } });
    jest.clearAllMocks();
  });

  afterEach(() => jest.clearAllMocks());

  // ── POST /api/v1/chat/message ─────────────────────────────────────────────
  describe("POST /api/v1/chat/message", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app)
        .post("/api/v1/chat/message")
        .send({ message: "What coffee do you recommend?" });
      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });

    it("should return 400 when message is missing", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/chat/message")
        .set("Authorization", "Bearer token")
        .send({});
      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it("should return 400 when message is an empty string", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/chat/message")
        .set("Authorization", "Bearer token")
        .send({ message: "" });
      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it("should create a new chat session and return a reply", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/chat/message")
        .set("Authorization", "Bearer token")
        .send({ message: "What coffee do you recommend?" });
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.reply).toBeDefined();
      expect(res.body.data.sessionId).toBeDefined();
      expect(typeof res.body.data.reply).toBe("string");
    });

    it("should continue an existing session when sessionId is provided", async () => {
      // Create initial message to get a sessionId
      mockAuth();
      const first = await request(app)
        .post("/api/v1/chat/message")
        .set("Authorization", "Bearer token")
        .send({ message: "Hello!" });
      expect(first.status).toBe(200);
      const sessionId = first.body.data.sessionId;

      // Continue the session
      mockAuth();
      const res = await request(app)
        .post("/api/v1/chat/message")
        .set("Authorization", "Bearer token")
        .send({ message: "Tell me more about your espresso.", sessionId });
      expect(res.status).toBe(200);
      expect(res.body.data.sessionId).toBe(sessionId);
    });

    it("should return 404 when a non-existent sessionId is provided", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/chat/message")
        .set("Authorization", "Bearer token")
        .send({
          message: "Hello!",
          sessionId: "nonexistentid000000000000",
        });
      expect(res.status).toBe(404);
    });
  });
});
