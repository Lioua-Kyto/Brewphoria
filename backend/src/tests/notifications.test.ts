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

const USER_UID = "notif-test-uid";
const USER_EMAIL = "notif-test@brewphoria.com";

function mockAuth() {
  (
    mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
      typeof mockFirebaseAuth.verifyIdToken
    >
  ).mockResolvedValueOnce({
    uid: USER_UID,
    email: USER_EMAIL,
    name: "Notif Test",
  } as never);
}

describe("Notification Routes", () => {
  let userId: string;
  let notificationId: string;

  beforeAll(async () => {
    const user = await prisma.user.upsert({
      where: { firebaseUid: USER_UID },
      create: {
        firebaseUid: USER_UID,
        email: USER_EMAIL,
        displayName: "Notif Test",
        loyaltyAccount: {
          create: { currentPoints: 0, lifetimePoints: 0, tier: "BRONZE" },
        },
      },
      update: {},
    });
    userId = user.id;

    const notif = await prisma.notification.create({
      data: {
        userId,
        type: "ORDER_STATUS_CHANGED",
        title: "Order Shipped",
        body: "Your order is on the way!",
        isRead: false,
      },
    });
    notificationId = notif.id;
  });

  afterAll(async () => {
    await prisma.notification.deleteMany({ where: { userId } });
    await prisma.loyaltyAccount.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { id: userId } });
    jest.clearAllMocks();
  });

  afterEach(() => jest.clearAllMocks());

  // ── GET /api/v1/notifications ────────────────────────────────────────────────
  describe("GET /api/v1/notifications", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app).get("/api/v1/notifications");
      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });

    it("should return paginated notifications for the authenticated user", async () => {
      mockAuth();
      const res = await request(app)
        .get("/api/v1/notifications")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThan(0);
      expect(res.body.data[0].title).toBe("Order Shipped");
      expect(res.body.data[0].isRead).toBe(false);
    });

    it("should support pagination with page and limit query params", async () => {
      mockAuth();
      const res = await request(app)
        .get("/api/v1/notifications?page=1&limit=5")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.meta).toBeDefined();
      expect(res.body.meta.limit).toBe(5);
    });
  });

  // ── PATCH /api/v1/notifications/:id/read ────────────────────────────────────
  describe("PATCH /api/v1/notifications/:id/read", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app).patch(
        `/api/v1/notifications/${notificationId}/read`,
      );
      expect(res.status).toBe(401);
    });

    it("should return 404 for a non-existent notification", async () => {
      mockAuth();
      const res = await request(app)
        .patch("/api/v1/notifications/nonexistentid000000000000/read")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(404);
    });

    it("should mark a specific notification as read", async () => {
      mockAuth();
      const res = await request(app)
        .patch(`/api/v1/notifications/${notificationId}/read`)
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.isRead).toBe(true);
    });
  });

  // ── PATCH /api/v1/notifications/read-all ────────────────────────────────────
  describe("PATCH /api/v1/notifications/read-all", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app).patch("/api/v1/notifications/read-all");
      expect(res.status).toBe(401);
    });

    it("should mark all notifications as read", async () => {
      // Create another unread notification
      await prisma.notification.create({
        data: {
          userId,
          type: "LOYALTY_TIER_UP",
          title: "Tier Up!",
          body: "You reached Silver tier!",
          isRead: false,
        },
      });

      mockAuth();
      const res = await request(app)
        .patch("/api/v1/notifications/read-all")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);

      // Verify all are read in DB
      const unread = await prisma.notification.findMany({
        where: { userId, isRead: false },
      });
      expect(unread.length).toBe(0);
    });
  });
});
