import { Review } from "@prisma/client";
import { ReviewRepository } from "../repositories/ReviewRepository";
import { ProductRepository } from "../repositories/ProductRepository";
import { prisma } from "../config/database";
import {
  NotFoundError,
  ForbiddenError,
  ConflictError,
  BadRequestError,
} from "../utils/errors";
import { buildPaginatedResult, PaginatedResult } from "../utils/pagination";

const reviewRepo = new ReviewRepository();
const productRepo = new ProductRepository();

export class ReviewService {
  async create(
    userId: string,
    data: {
      orderItemId: string;
      rating: number;
      comment: string;
      images?: string[];
    },
  ): Promise<Review> {
    // 1. Fetch order item and validate ownership
    const orderItem = await prisma.orderItem.findUnique({
      where: { id: data.orderItemId },
      include: { order: { select: { userId: true, status: true } } },
    });
    if (!orderItem) throw new NotFoundError("Order item");
    if (orderItem.order.userId !== userId)
      throw new ForbiddenError("Not your order");
    if (orderItem.order.status !== "DELIVERED") {
      throw new BadRequestError("Can only review items from delivered orders");
    }

    // 2. Check for duplicate review
    const existing = await reviewRepo.findByOrderItemId(data.orderItemId);
    if (existing)
      throw new ConflictError("You have already reviewed this item");

    // 3. Create review
    const review = await reviewRepo.create({
      user: { connect: { id: userId } },
      product: { connect: { id: orderItem.productId } },
      orderItem: { connect: { id: data.orderItemId } },
      rating: data.rating,
      comment: data.comment,
      images: data.images ?? [],
    });

    // 4. Update product average rating
    await productRepo.updateRating(orderItem.productId);

    return review;
  }

  async update(
    userId: string,
    reviewId: string,
    data: Partial<{ rating: number; comment: string; images: string[] }>,
  ): Promise<Review> {
    const review = await reviewRepo.findById(reviewId);
    if (!review) throw new NotFoundError("Review");
    if (review.userId !== userId) throw new ForbiddenError("Not your review");

    const updated = await reviewRepo.update(reviewId, data);
    await productRepo.updateRating(review.productId);
    return updated;
  }

  async delete(userId: string, reviewId: string): Promise<void> {
    const review = await reviewRepo.findById(reviewId);
    if (!review) throw new NotFoundError("Review");
    if (review.userId !== userId) throw new ForbiddenError("Not your review");

    await reviewRepo.delete(reviewId);
    await productRepo.updateRating(review.productId);
  }

  async getProductReviews(
    productId: string,
    page: number,
    limit: number,
  ): Promise<PaginatedResult<Review>> {
    const { data, total } = await reviewRepo.findMany({
      productId,
      isVisible: true,
      page,
      limit,
    });
    return buildPaginatedResult(data, total, page, limit);
  }

  async adminList(filters: {
    productId?: string;
    rating?: number;
    page: number;
    limit: number;
  }): Promise<PaginatedResult<Review>> {
    const { data, total } = await reviewRepo.findMany(filters);
    return buildPaginatedResult(data, total, filters.page, filters.limit);
  }

  async updateVisibility(
    reviewId: string,
    isVisible: boolean,
  ): Promise<Review> {
    const review = await reviewRepo.findById(reviewId);
    if (!review) throw new NotFoundError("Review");
    const updated = await reviewRepo.updateVisibility(reviewId, isVisible);
    await productRepo.updateRating(review.productId);
    return updated;
  }
}
