import { Router } from "express";
import { ChatController } from "../controllers/ChatController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";
import { chatRateLimiter } from "../middleware/rateLimiter";

const router = Router();
const ctrl = new ChatController();

router.use(authenticate, chatRateLimiter);

router.post("/message", asyncHandler(ctrl.sendMessage.bind(ctrl)));

export default router;
