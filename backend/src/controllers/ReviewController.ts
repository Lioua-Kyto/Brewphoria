import { Request, Response } from "express";
import { z } from "zod";
import { ReviewService } from "../services/ReviewService";
import { sendSuccess } from "../utils/response";
import { paginationSchema } from "../utils/pagination";

const reviewService = new ReviewService();

const createReviewSchema = z.object({
  orderItemId: z.string().cuid(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().min(10).max(1000),
  images: z.array(z.string().url()).max(3).optional(),
});

const updateReviewSchema = z.object({
  rating: z.number().int().min(1).max(5).optional(),
  comment: z.string().min(10).max(1000).optional(),
  images: z.array(z.string().url()).max(3).optional(),
});

const adminReviewQuerySchema = paginationSchema.extend({
  productId: z.string().optional(),
  rating: z.coerce.number().int().min(1).max(5).optional(),
});

const visibilitySchema = z.object({
  isVisible: z.boolean(),
});

export class ReviewController {
  async create(req: Request, res: Response): Promise<void> {
    const parsed = createReviewSchema.parse(req.body);
    const review = await reviewService.create(req.user!.id, parsed);
    sendSuccess(res, review, "Review created", 201);
  }

  async update(req: Request, res: Response): Promise<void> {
    const parsed = updateReviewSchema.parse(req.body);
    const review = await reviewService.update(
      req.user!.id,
      req.params["id"]!,
      parsed,
    );
    sendSuccess(res, review, "Review updated");
  }

  async delete(req: Request, res: Response): Promise<void> {
    await reviewService.delete(req.user!.id, req.params["id"]!);
    sendSuccess(res, null, "Review deleted");
  }

  async adminList(req: Request, res: Response): Promise<void> {
    const query = adminReviewQuerySchema.parse(req.query);
    const result = await reviewService.adminList(query);
    sendSuccess(res, result.data, "Reviews retrieved", 200, result.meta);
  }

  async adminUpdateVisibility(req: Request, res: Response): Promise<void> {
    const parsed = visibilitySchema.parse(req.body);
    const review = await reviewService.updateVisibility(
      req.params["id"]!,
      parsed.isVisible,
    );
    sendSuccess(res, review, "Review visibility updated");
  }
}
