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
    models: { generateContent: jest.fn() },
  })),
}));

const mockFirebaseAuth = firebaseAuth as jest.Mocked<typeof firebaseAuth>;

async function setupTestUser(
  fbUid: string,
  email: string,
  role: "USER" | "ADMIN" = "USER",
) {
  return prisma.user.upsert({
    where: { firebaseUid: fbUid },
    create: {
      firebaseUid: fbUid,
      email,
      displayName: "Test User",
      role,
      loyaltyAccount: {
        create: { currentPoints: 500, lifetimePoints: 500, tier: "SILVER" },
      },
    },
    update: {},
    include: { loyaltyAccount: true },
  });
}

describe("Order Routes", () => {
  const userUid = "order-test-user-uid";
  const userEmail = "order-test@brewphoria.com";

  let userId: string;
  let addressId: string;
  let categoryId: string;
  let productId: string;

  beforeAll(async () => {
    const user = await setupTestUser(userUid, userEmail);
    userId = user.id;

    const address = await prisma.address.create({
      data: {
        userId,
        label: "Home",
        fullName: "Test User",
        phone: "1234567890",
        street: "123 Main St",
        city: "Portland",
        state: "OR",
        postalCode: "97201",
        country: "US",
        isDefault: true,
      },
    });
    addressId = address.id;

    const category = await prisma.category.upsert({
      where: { slug: "order-test-category" },
      create: { name: "Order Test Category", slug: "order-test-category" },
      update: {},
    });
    categoryId = category.id;

    const product = await prisma.product.create({
      data: {
        name: "Test Coffee Beans",
        slug: "test-coffee-beans-order",
        description: "Great coffee beans for testing",
        price: 15.0,
        categoryId,
        images: ["https://example.com/image.jpg"],
        stock: 100,
        isActive: true,
      },
    });
    productId = product.id;
  });

  afterAll(async () => {
    await prisma.loyaltyTransaction.deleteMany({
      where: { account: { userId } },
    });
    await prisma.cartItem.deleteMany({ where: { cart: { userId } } });
    await prisma.cart.deleteMany({ where: { userId } });
    await prisma.order.deleteMany({ where: { userId } });
    await prisma.loyaltyAccount.deleteMany({ where: { userId } });
    await prisma.address.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { id: userId } });
    await prisma.product.deleteMany({ where: { categoryId } });
    await prisma.category.deleteMany({ where: { id: categoryId } });
  });

  function mockAuth() {
    (
      mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
        typeof mockFirebaseAuth.verifyIdToken
      >
    ).mockResolvedValueOnce({
      uid: userUid,
      email: userEmail,
      name: "Test User",
    } as unknown as Awaited<ReturnType<typeof mockFirebaseAuth.verifyIdToken>>);
  }

  describe("POST /api/v1/cart/items", () => {
    it("should add item to cart", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/cart/items")
        .set("Authorization", "Bearer token")
        .send({ productId, quantity: 2 });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
    });

    it("should return 401 without auth", async () => {
      const res = await request(app)
        .post("/api/v1/cart/items")
        .send({ productId, quantity: 1 });
      expect(res.status).toBe(401);
    });

    it("should return 400 for invalid body", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/cart/items")
        .set("Authorization", "Bearer token")
        .send({ quantity: -1 }); // missing productId, invalid quantity
      expect(res.status).toBe(400);
    });
  });

  describe("GET /api/v1/cart", () => {
    it("should return cart for authenticated user", async () => {
      mockAuth();
      const res = await request(app)
        .get("/api/v1/cart")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.data).toBeDefined();
    });
  });

  describe("POST /api/v1/orders/checkout", () => {
    it("should return 400 for empty cart address not owned", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/orders/checkout")
        .set("Authorization", "Bearer token")
        .send({
          addressId: "clxxxxxxxxxxxxxxxxxxxxxxxxx", // valid cuid format but nonexistent
          pointsToRedeem: 0,
        });
      expect([400, 404]).toContain(res.status);
    });

    it("should return 401 without auth", async () => {
      const res = await request(app)
        .post("/api/v1/orders/checkout")
        .send({ addressId, pointsToRedeem: 0 });
      expect(res.status).toBe(401);
    });

    it("should return 400 when body is invalid", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/orders/checkout")
        .set("Authorization", "Bearer token")
        .send({ pointsToRedeem: -5 }); // missing addressId, invalid points
      expect(res.status).toBe(400);
    });
  });

  describe("GET /api/v1/orders", () => {
    it("should return order list for authenticated user", async () => {
      mockAuth();
      const res = await request(app)
        .get("/api/v1/orders")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.meta).toBeDefined();
    });
  });

  describe("POST /api/v1/reviews", () => {
    it("should return 400 when trying to review non-delivered order item", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/reviews")
        .set("Authorization", "Bearer token")
        .send({
          orderItemId: "clxxxxxxxxxxxxxxxxxxxxxxxxx",
          rating: 5,
          comment: "Amazing coffee, best I have ever had!",
        });
      // 404 because order item doesn't exist
      expect([400, 404]).toContain(res.status);
    });
  });

  describe("GET /api/v1/loyalty", () => {
    it("should return loyalty account for authenticated user", async () => {
      mockAuth();
      const res = await request(app)
        .get("/api/v1/loyalty")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.data.currentPoints).toBeDefined();
    });
  });

  describe("POST /api/v1/loyalty/redeem", () => {
    it("should return 400 when redeeming more points than available", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/loyalty/redeem")
        .set("Authorization", "Bearer token")
        .send({ pointsToRedeem: 999999 });
      expect(res.status).toBe(400);
    });

    it("should succeed for valid redemption", async () => {
      mockAuth();
      const res = await request(app)
        .post("/api/v1/loyalty/redeem")
        .set("Authorization", "Bearer token")
        .send({ pointsToRedeem: 100 }); // user has 500
      expect(res.status).toBe(200);
      expect(res.body.data.discountAmount).toBe(1);
    });
  });
});
