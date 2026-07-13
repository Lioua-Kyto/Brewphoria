import request from "supertest";
import app from "../app";
import { prisma } from "../config/database";
import { firebaseAuth } from "../config/firebase";
import { jest } from "@jest/globals";

jest.mock("../config/firebase", () => ({
  firebaseAuth: { verifyIdToken: jest.fn() },
  firebaseMessaging: { send: jest.fn().mockResolvedValue("id" as never) },
  firebaseApp: {},
}));

const mockFirebaseAuth = firebaseAuth as jest.Mocked<typeof firebaseAuth>;

async function createTestCategory(name = "Test Coffee") {
  return prisma.category.upsert({
    where: { slug: name.toLowerCase().replace(/\s+/g, "-") },
    create: {
      name,
      slug: name.toLowerCase().replace(/\s+/g, "-"),
      isActive: true,
    },
    update: {},
  });
}

async function createTestProduct(categoryId: string, suffix = "") {
  return prisma.product.create({
    data: {
      name: `Espresso Blend${suffix}`,
      slug: `espresso-blend${suffix.toLowerCase().replace(/\s+/g, "-")}`,
      description: "A rich, full-bodied espresso blend",
      price: 18.99,
      categoryId,
      images: ["https://example.com/img.jpg"],
      stock: 50,
      isActive: true,
    },
  });
}

describe("Product Routes", () => {
  let categoryId: string;
  let productSlug: string;

  beforeAll(async () => {
    const cat = await createTestCategory("Espresso");
    categoryId = cat.id;
    const prod = await createTestProduct(categoryId, "-list-test");
    productSlug = prod.slug;
  });

  afterAll(async () => {
    await prisma.product.deleteMany({ where: { categoryId } });
    await prisma.category.delete({ where: { id: categoryId } }).catch(() => {});
  });

  describe("GET /api/v1/products", () => {
    it("should return paginated product list", async () => {
      const res = await request(app).get("/api/v1/products");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.meta).toBeDefined();
      expect(res.body.meta.page).toBe(1);
    });

    it("should filter by category", async () => {
      const res = await request(app).get(
        `/api/v1/products?category=${categoryId}`,
      );
      expect(res.status).toBe(200);
      expect(
        res.body.data.every(
          (p: { categoryId: string }) => p.categoryId === categoryId,
        ),
      ).toBe(true);
    });

    it("should support search query", async () => {
      const res = await request(app).get("/api/v1/products?search=Espresso");
      expect(res.status).toBe(200);
    });

    it("should enforce pagination with limit", async () => {
      const res = await request(app).get("/api/v1/products?limit=5&page=1");
      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeLessThanOrEqual(5);
    });
  });

  describe("GET /api/v1/products/:slug", () => {
    it("should return product by slug", async () => {
      const res = await request(app).get(`/api/v1/products/${productSlug}`);
      expect(res.status).toBe(200);
      expect(res.body.data.slug).toBe(productSlug);
    });

    it("should return 404 for non-existent product", async () => {
      const res = await request(app).get(
        "/api/v1/products/non-existent-slug-xyz",
      );
      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
    });
  });

  describe("GET /api/v1/categories", () => {
    it("should return active categories", async () => {
      const res = await request(app).get("/api/v1/categories");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Admin product routes", () => {
    it("should return 401 without auth", async () => {
      const res = await request(app).post("/api/v1/admin/products");
      expect(res.status).toBe(401);
    });

    it("should return 403 for non-admin user", async () => {
      const nonAdminUid = "non-admin-uid-products";
      (
        mockFirebaseAuth.verifyIdToken as jest.MockedFunction<
          typeof mockFirebaseAuth.verifyIdToken
        >
      ).mockResolvedValueOnce({
        uid: nonAdminUid,
        email: "user@test.com",
        name: "User",
      } as unknown as Awaited<
        ReturnType<typeof mockFirebaseAuth.verifyIdToken>
      >);

      // Create non-admin user
      await prisma.user.upsert({
        where: { firebaseUid: nonAdminUid },
        create: {
          firebaseUid: nonAdminUid,
          email: "non-admin-prod@test.com",
          displayName: "Non Admin",
          role: "USER",
          loyaltyAccount: { create: {} },
        },
        update: {},
      });

      const res = await request(app)
        .post("/api/v1/admin/products")
        .set("Authorization", "Bearer token");

      expect(res.status).toBe(403);

      await prisma.loyaltyAccount.deleteMany({
        where: { user: { firebaseUid: nonAdminUid } },
      });
      await prisma.user.deleteMany({ where: { firebaseUid: nonAdminUid } });
    });
  });
});
