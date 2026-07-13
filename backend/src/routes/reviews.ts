import { Router } from "express";
import { ReviewController } from "../controllers/ReviewController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new ReviewController();

router.use(authenticate);

router.post("/", asyncHandler(ctrl.create.bind(ctrl)));
router.patch("/:id", asyncHandler(ctrl.update.bind(ctrl)));
router.delete("/:id", asyncHandler(ctrl.delete.bind(ctrl)));

export default router;
