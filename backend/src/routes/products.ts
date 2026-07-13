import { Router } from "express";
import { ProductController } from "../controllers/ProductController";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new ProductController();

router.get("/", asyncHandler(ctrl.list.bind(ctrl)));
router.get("/:slug", asyncHandler(ctrl.getBySlug.bind(ctrl)));
router.get("/:id/reviews", asyncHandler(ctrl.getReviews.bind(ctrl)));
router.get(
  "/:id/reviews/summary",
  asyncHandler(ctrl.getReviewSummary.bind(ctrl)),
);

export default router;
