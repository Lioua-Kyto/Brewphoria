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

const ADMIN_UID = "admin-test-uid";
const ADMIN_EMAIL = "admin-test@brewphoria.com";
const USER_UID = "admin-nonadmin-uid";
const USER_EMAIL = "admin-nonadmin@brewphoria.com";

function mockAuth(uid: string, email: string) {
  (
    mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
      typeof mockFirebaseAuth.verifyIdToken
    >
  ).mockResolvedValueOnce({ uid, email, name: "Test" } as never);
}
function mockAdmin() {
  mockAuth(ADMIN_UID, ADMIN_EMAIL);
}
function mockUser() {
  mockAuth(USER_UID, USER_EMAIL);
}

describe("Admin Routes", () => {
  let adminId: string;
  let regularUserId: string;
  let categoryId: string;
  let productId: string;
  let orderId: string;
  let orderUserId: string;

  beforeAll(async () => {
    const admin = await prisma.user.upsert({
      where: { firebaseUid: ADMIN_UID },
      create: {
        firebaseUid: ADMIN_UID,
        email: ADMIN_EMAIL,
        displayName: "Admin User",
        role: "ADMIN",
        loyaltyAccount: {
          create: { currentPoints: 0, lifetimePoints: 0, tier: "BRONZE" },
        },
      },
      update: { role: "ADMIN" },
    });
    adminId = admin.id;

    const user = await prisma.user.upsert({
      where: { firebaseUid: USER_UID },
      create: {
        firebaseUid: USER_UID,
        email: USER_EMAIL,
        displayName: "Regular User",
        role: "USER",
        loyaltyAccount: {
          create: { currentPoints: 0, lifetimePoints: 0, tier: "BRONZE" },
        },
      },
      update: {},
    });
    regularUserId = user.id;

    // Seed a category and product for use across tests
    const category = await prisma.category.upsert({
      where: { slug: "admin-test-category" },
      create: {
        name: "Admin Test Category",
        slug: "admin-test-category",
        isActive: true,
      },
      update: {},
    });
    categoryId = category.id;

    const product = await prisma.product.create({
      data: {
        name: "Admin Test Latte",
        slug: "admin-test-latte",
        description: "A latte for admin tests",
        price: 5.0,
        categoryId,
        images: [],
        stock: 50,
        isActive: true,
      },
    });
    productId = product.id;

    // Create an order for order-management tests
    const orderUser = await prisma.user.upsert({
      where: { firebaseUid: "admin-order-user-uid" },
      create: {
        firebaseUid: "admin-order-user-uid",
        email: "admin-order-user@brewphoria.com",
        displayName: "Order User",
        loyaltyAccount: {
          create: { currentPoints: 0, lifetimePoints: 0, tier: "BRONZE" },
        },
      },
      update: {},
    });
    orderUserId = orderUser.id;

    const address = await prisma.address.create({
      data: {
        userId: orderUserId,
        label: "Home",
        fullName: "Order User",
        phone: "5556667777",
        street: "1 Test St",
        city: "Portland",
        state: "OR",
        postalCode: "97201",
        country: "US",
      },
    });

    const order = await prisma.order.create({
      data: {
        userId: orderUserId,
        addressId: address.id,
        subtotal: 5.0,
        deliveryFee: 2.0,
        total: 7.0,
        status: "CONFIRMED",
        items: {
          create: {
            productId,
            productName: "Admin Test Latte",
            productImage: "https://example.com/latte.jpg",
            unitPrice: 5.0,
            quantity: 1,
            subtotal: 5.0,
          },
        },
      },
    });
    orderId = order.id;
  });

  afterAll(async () => {
    await prisma.order.deleteMany({ where: { userId: orderUserId } });
    await prisma.address.deleteMany({ where: { userId: orderUserId } });
    await prisma.loyaltyAccount.deleteMany({ where: { userId: orderUserId } });
    await prisma.user.deleteMany({ where: { id: orderUserId } });
    await prisma.product.deleteMany({ where: { categoryId } });
    await prisma.category.deleteMany({ where: { id: categoryId } });
    await prisma.loyaltyAccount.deleteMany({ where: { userId: adminId } });
    await prisma.loyaltyAccount.deleteMany({
      where: { userId: regularUserId },
    });
    await prisma.user.deleteMany({
      where: { id: { in: [adminId, regularUserId] } },
    });
    jest.clearAllMocks();
  });

  afterEach(() => jest.clearAllMocks());

  // ── GET /api/v1/admin/dashboard ──────────────────────────────────────────────
  describe("GET /api/v1/admin/dashboard", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app).get("/api/v1/admin/dashboard");
      expect(res.status).toBe(401);
    });

    it("should return 403 for a regular user", async () => {
      mockUser();
      const res = await request(app)
        .get("/api/v1/admin/dashboard")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(403);
    });

    it("should return dashboard stats for an admin", async () => {
      mockAdmin();
      const res = await request(app)
        .get("/api/v1/admin/dashboard")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toBeDefined();
    });
  });

  // ── GET /api/v1/admin/notifications ─────────────────────────────────────────
  describe("GET /api/v1/admin/notifications", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app).get("/api/v1/admin/notifications");
      expect(res.status).toBe(401);
    });

    it("should return 403 for a regular user", async () => {
      mockUser();
      const res = await request(app)
        .get("/api/v1/admin/notifications")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(403);
    });

    it("should return notifications list for admin", async () => {
      mockAdmin();
      const res = await request(app)
        .get("/api/v1/admin/notifications")
        .set("Authorization", "Bearer token");
      expect(res.status).toBe(200);
    });
  });

  // ── Admin Products ───────────────────────────────────────────────────────────
  describe("Admin Products", () => {
    let newProductId: string;

    describe("GET /api/v1/admin/products", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).get("/api/v1/admin/products");
        expect(res.status).toBe(401);
      });

      it("should return 403 for a regular user", async () => {
        mockUser();
        const res = await request(app)
          .get("/api/v1/admin/products")
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(403);
      });

      it("should return all products (including inactive) for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .get("/api/v1/admin/products")
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(Array.isArray(res.body.data)).toBe(true);
      });
    });

    describe("POST /api/v1/admin/products", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).post("/api/v1/admin/products");
        expect(res.status).toBe(401);
      });

      it("should return 403 for a regular user", async () => {
        mockUser();
        const res = await request(app)
          .post("/api/v1/admin/products")
          .set("Authorization", "Bearer token")
          .field("name", "Latte")
          .field("description", "A nice latte")
          .field("price", "4.50")
          .field("categoryId", categoryId)
          .field("stock", "30");
        expect(res.status).toBe(403);
      });

      it("should return 400 when required fields are missing", async () => {
        mockAdmin();
        const res = await request(app)
          .post("/api/v1/admin/products")
          .set("Authorization", "Bearer token")
          .field("name", "Incomplete Latte"); // missing description, price, categoryId, stock
        expect(res.status).toBe(400);
      });

      it("should create a new product for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .post("/api/v1/admin/products")
          .set("Authorization", "Bearer token")
          .field("name", "New Test Mocha")
          .field("description", "A delicious mocha for testing")
          .field("price", "5.50")
          .field("categoryId", categoryId)
          .field("stock", "25")
          .field("isFeatured", "true");
        expect(res.status).toBe(201);
        expect(res.body.data.name).toBe("New Test Mocha");
        newProductId = res.body.data.id;
      });
    });

    describe("PATCH /api/v1/admin/products/:id", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).patch(
          `/api/v1/admin/products/${productId}`,
        );
        expect(res.status).toBe(401);
      });

      it("should return 403 for a regular user", async () => {
        mockUser();
        const res = await request(app)
          .patch(`/api/v1/admin/products/${productId}`)
          .set("Authorization", "Bearer token")
          .field("stock", "99");
        expect(res.status).toBe(403);
      });

      it("should update a product for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .patch(`/api/v1/admin/products/${productId}`)
          .set("Authorization", "Bearer token")
          .field("stock", "999");
        expect(res.status).toBe(200);
        expect(Number(res.body.data.stock)).toBe(999);
      });
    });

    describe("DELETE /api/v1/admin/products/:id", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).delete(
          `/api/v1/admin/products/${newProductId}`,
        );
        expect(res.status).toBe(401);
      });

      it("should return 403 for a regular user", async () => {
        mockUser();
        const res = await request(app)
          .delete(`/api/v1/admin/products/${newProductId}`)
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(403);
      });

      it("should soft-delete a product for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .delete(`/api/v1/admin/products/${newProductId}`)
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(200);

        // Verify the product is deactivated (soft-deleted), not removed
        const product = await prisma.product.findUnique({
          where: { id: newProductId },
        });
        expect(product?.isActive).toBe(false);
      });
    });
  });

  // ── Admin Categories ─────────────────────────────────────────────────────────
  describe("Admin Categories", () => {
    let newCategoryId: string;

    describe("GET /api/v1/admin/categories", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).get("/api/v1/admin/categories");
        expect(res.status).toBe(401);
      });

      it("should return 403 for a regular user", async () => {
        mockUser();
        const res = await request(app)
          .get("/api/v1/admin/categories")
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(403);
      });

      it("should return all categories for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .get("/api/v1/admin/categories")
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(200);
        expect(Array.isArray(res.body.data)).toBe(true);
      });
    });

    describe("POST /api/v1/admin/categories", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).post("/api/v1/admin/categories");
        expect(res.status).toBe(401);
      });

      it("should return 400 when required fields are missing", async () => {
        mockAdmin();
        const res = await request(app)
          .post("/api/v1/admin/categories")
          .set("Authorization", "Bearer token")
          .send({}); // missing name
        expect(res.status).toBe(400);
      });

      it("should create a new category for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .post("/api/v1/admin/categories")
          .set("Authorization", "Bearer token")
          .send({ name: "Admin New Tea Category" });
        expect(res.status).toBe(201);
        expect(res.body.data.name).toBe("Admin New Tea Category");
        newCategoryId = res.body.data.id;
      });
    });

    describe("PATCH /api/v1/admin/categories/:id", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).patch(
          `/api/v1/admin/categories/${newCategoryId}`,
        );
        expect(res.status).toBe(401);
      });

      it("should update a category for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .patch(`/api/v1/admin/categories/${newCategoryId}`)
          .set("Authorization", "Bearer token")
          .send({ name: "Admin Updated Tea Category" });
        expect(res.status).toBe(200);
        expect(res.body.data.name).toBe("Admin Updated Tea Category");
      });
    });

    describe("DELETE /api/v1/admin/categories/:id", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).delete(
          `/api/v1/admin/categories/${newCategoryId}`,
        );
        expect(res.status).toBe(401);
      });

      it("should delete a category for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .delete(`/api/v1/admin/categories/${newCategoryId}`)
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(200);
      });
    });
  });

  // ── Admin Orders ─────────────────────────────────────────────────────────────
  describe("Admin Orders", () => {
    describe("GET /api/v1/admin/orders", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app).get("/api/v1/admin/orders");
        expect(res.status).toBe(401);
      });

      it("should return 403 for a regular user", async () => {
        mockUser();
        const res = await request(app)
          .get("/api/v1/admin/orders")
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(403);
      });

      it("should return all orders for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .get("/api/v1/admin/orders")
          .set("Authorization", "Bearer token");
        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(Array.isArray(res.body.data)).toBe(true);
      });
    });

    describe("PATCH /api/v1/admin/orders/:id/status", () => {
      it("should return 401 without auth", async () => {
        const res = await request(app)
          .patch(`/api/v1/admin/orders/${orderId}/status`)
          .send({ status: "PREPARING" });
        expect(res.status).toBe(401);
      });

      it("should return 403 for a regular user", async () => {
        mockUser();
        const res = await request(app)
          .patch(`/api/v1/admin/orders/${orderId}/status`)
          .set("Authorization", "Bearer token")
          .send({ status: "PREPARING" });
        expect(res.status).toBe(403);
      });

      it("should return 400 for an invalid order status", async () => {
        mockAdmin();
        const res = await request(app)
          .patch(`/api/v1/admin/orders/${orderId}/status`)
          .set("Authorization", "Bearer token")
          .send({ status: "INVALID_STATUS" });
        expect(res.status).toBe(400);
      });

      it("should update order status for admin", async () => {
        mockAdmin();
        const res = await request(app)
          .patch(`/api/v1/admin/orders/${orderId}/status`)
          .set("Authorization", "Bearer token")
          .send({ status: "PREPARING" });
        expect(res.status).toBe(200);
        expect(res.body.data.status).toBe("PREPARING");
      });

      it("should return 404 for a non-existent order", async () => {
        mockAdmin();
        const res = await request(app)
          .patch("/api/v1/admin/orders/nonexistentid000000000000/status")
          .set("Authorization", "Bearer token")
          .send({ status: "DELIVERED" });
        expect(res.status).toBe(404);
      });
    });
  });
});
