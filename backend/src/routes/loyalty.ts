import { Router } from "express";
import { LoyaltyController } from "../controllers/LoyaltyController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new LoyaltyController();

router.use(authenticate);

router.get("/", asyncHandler(ctrl.getAccount.bind(ctrl)));
router.get("/history", asyncHandler(ctrl.getHistory.bind(ctrl)));
router.post("/redeem", asyncHandler(ctrl.redeem.bind(ctrl)));

export default router;
