import { Prisma, Product } from "@prisma/client";
import { prisma } from "../config/database";

export type ProductSort = "newest" | "price_asc" | "price_desc" | "rating";

export interface ProductFilters {
  categoryId?: string;
  minPrice?: number;
  maxPrice?: number;
  isFeatured?: boolean;
  search?: string;
  isActive?: boolean;
  sort?: ProductSort;
  page: number;
  limit: number;
}

const PRODUCT_ORDER_BY: Record<
  ProductSort,
  Prisma.ProductOrderByWithRelationInput | Prisma.ProductOrderByWithRelationInput[]
> = {
  newest: { createdAt: "desc" },
  price_asc: { price: "asc" },
  price_desc: { price: "desc" },
  rating: [{ avgRating: "desc" }, { reviewCount: "desc" }],
};

export class ProductRepository {
  private buildWhere(
    filters: Omit<ProductFilters, "page" | "limit">,
  ): Prisma.ProductWhereInput {
    const where: Prisma.ProductWhereInput = {};

    if (filters.isActive !== undefined) where.isActive = filters.isActive;
    if (filters.categoryId) where.categoryId = filters.categoryId;
    if (filters.isFeatured !== undefined) where.isFeatured = filters.isFeatured;
    if (filters.minPrice !== undefined || filters.maxPrice !== undefined) {
      where.price = {
        ...(filters.minPrice !== undefined ? { gte: filters.minPrice } : {}),
        ...(filters.maxPrice !== undefined ? { lte: filters.maxPrice } : {}),
      };
    }
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: "insensitive" } },
        { description: { contains: filters.search, mode: "insensitive" } },
      ];
    }

    return where;
  }

  async findMany(
    filters: ProductFilters,
  ): Promise<{ data: Product[]; total: number }> {
    const { page, limit, sort, ...rest } = filters;
    const where = this.buildWhere(rest);
    const skip = (page - 1) * limit;

    const [data, total] = await prisma.$transaction([
      prisma.product.findMany({
        where,
        skip,
        take: limit,
        include: { category: { select: { id: true, name: true, slug: true } } },
        orderBy: PRODUCT_ORDER_BY[sort ?? "newest"],
      }),
      prisma.product.count({ where }),
    ]);

    return { data, total };
  }

  async findBySlug(
    slug: string,
  ): Promise<
    (Product & { category: { id: string; name: string; slug: string } }) | null
  > {
    return prisma.product.findUnique({
      where: { slug },
      include: { category: { select: { id: true, name: true, slug: true } } },
    });
  }

  async findById(id: string): Promise<Product | null> {
    return prisma.product.findUnique({ where: { id } });
  }

  async findByIds(ids: string[]): Promise<Product[]> {
    return prisma.product.findMany({
      where: { id: { in: ids }, isActive: true },
    });
  }

  async findTopProducts(limit = 20): Promise<Product[]> {
    return prisma.product.findMany({
      where: { isActive: true },
      orderBy: [{ avgRating: "desc" }, { reviewCount: "desc" }],
      take: limit,
      include: { category: { select: { id: true, name: true, slug: true } } },
    });
  }

  async create(data: Prisma.ProductCreateInput): Promise<Product> {
    return prisma.product.create({
      data,
      include: { category: { select: { id: true, name: true, slug: true } } },
    });
  }

  async update(id: string, data: Prisma.ProductUpdateInput): Promise<Product> {
    return prisma.product.update({
      where: { id },
      data,
      include: { category: { select: { id: true, name: true, slug: true } } },
    });
  }

  async softDelete(id: string): Promise<Product> {
    return prisma.product.update({ where: { id }, data: { isActive: false } });
  }

  async updateRating(productId: string): Promise<void> {
    const result = await prisma.review.aggregate({
      where: { productId, isVisible: true },
      _avg: { rating: true },
      _count: { rating: true },
    });
    await prisma.product.update({
      where: { id: productId },
      data: {
        avgRating: result._avg.rating ?? 0,
        reviewCount: result._count.rating,
      },
    });
  }

  async decrementStock(productId: string, quantity: number): Promise<void> {
    await prisma.product.update({
      where: { id: productId },
      data: { stock: { decrement: quantity } },
    });
  }
}
