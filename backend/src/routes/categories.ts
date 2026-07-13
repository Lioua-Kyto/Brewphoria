import { Router } from "express";
import { CategoryController } from "../controllers/CategoryController";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new CategoryController();

router.get("/", asyncHandler(ctrl.getAll.bind(ctrl)));

export default router;
