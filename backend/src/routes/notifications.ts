import { Router } from "express";
import { NotificationController } from "../controllers/NotificationController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new NotificationController();

router.use(authenticate);

router.get("/", asyncHandler(ctrl.getNotifications.bind(ctrl)));
router.patch("/read-all", asyncHandler(ctrl.markAllRead.bind(ctrl)));
router.patch("/:id/read", asyncHandler(ctrl.markRead.bind(ctrl)));

export default router;
