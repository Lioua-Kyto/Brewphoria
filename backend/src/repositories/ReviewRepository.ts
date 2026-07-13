import { Prisma, Review } from "@prisma/client";
import { prisma } from "../config/database";

export interface ReviewFilters {
  productId?: string;
  userId?: string;
  rating?: number;
  isVisible?: boolean;
  page: number;
  limit: number;
}

export class ReviewRepository {
  async findMany(
    filters: ReviewFilters,
  ): Promise<{ data: Review[]; total: number }> {
    const where: Prisma.ReviewWhereInput = {};
    if (filters.productId) where.productId = filters.productId;
    if (filters.userId) where.userId = filters.userId;
    if (filters.rating !== undefined) where.rating = filters.rating;
    if (filters.isVisible !== undefined) where.isVisible = filters.isVisible;

    const skip = (filters.page - 1) * filters.limit;
    const [data, total] = await prisma.$transaction([
      prisma.review.findMany({
        where,
        skip,
        take: filters.limit,
        include: {
          user: { select: { id: true, displayName: true, avatarUrl: true } },
        },
        orderBy: { createdAt: "desc" },
      }),
      prisma.review.count({ where }),
    ]);

    return { data, total };
  }

  async summary(
    productId: string,
  ): Promise<{ average: number; count: number; distribution: Record<1 | 2 | 3 | 4 | 5, number> }> {
    const where: Prisma.ReviewWhereInput = { productId, isVisible: true };
    const [agg, grouped] = await prisma.$transaction([
      prisma.review.aggregate({
        where,
        _avg: { rating: true },
        _count: { _all: true },
      }),
      prisma.review.groupBy({
        by: ["rating"],
        where,
        _count: { rating: true },
        orderBy: { rating: "asc" },
      }),
    ]);

    const distribution: Record<1 | 2 | 3 | 4 | 5, number> = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };
    for (const row of grouped as Array<{ rating: number; _count: { rating: number } }>) {
      distribution[row.rating as 1 | 2 | 3 | 4 | 5] = row._count.rating;
    }

    return {
      average: agg._avg.rating ?? 0,
      count: agg._count._all,
      distribution,
    };
  }

  async findById(id: string): Promise<Review | null> {
    return prisma.review.findUnique({ where: { id } });
  }

  async findByOrderItemId(orderItemId: string): Promise<Review | null> {
    return prisma.review.findUnique({ where: { orderItemId } });
  }

  async findByUserAndOrderItem(
    userId: string,
    orderItemId: string,
  ): Promise<Review | null> {
    return prisma.review.findUnique({
      where: { userId_orderItemId: { userId, orderItemId } },
    });
  }

  async create(data: Prisma.ReviewCreateInput): Promise<Review> {
    return prisma.review.create({ data });
  }

  async update(id: string, data: Prisma.ReviewUpdateInput): Promise<Review> {
    return prisma.review.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await prisma.review.delete({ where: { id } });
  }

  async updateVisibility(id: string, isVisible: boolean): Promise<Review> {
    return prisma.review.update({ where: { id }, data: { isVisible } });
  }
}
