import { Router } from "express";
import { AuthController } from "../controllers/AuthController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";
import { authRateLimiter } from "../middleware/rateLimiter";

const router = Router();
const ctrl = new AuthController();

router.post("/login", authRateLimiter, asyncHandler(ctrl.login.bind(ctrl)));
router.post("/logout", authenticate, asyncHandler(ctrl.logout.bind(ctrl)));
router.patch(
  "/fcm-token",
  authenticate,
  asyncHandler(ctrl.updateFcmToken.bind(ctrl)),
);

export default router;
