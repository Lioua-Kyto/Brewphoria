import { Router } from "express";
import { OrderController } from "../controllers/OrderController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new OrderController();

router.use(authenticate);

router.post("/checkout", asyncHandler(ctrl.checkout.bind(ctrl)));
router.get("/", asyncHandler(ctrl.getOrders.bind(ctrl)));
router.get("/:id", asyncHandler(ctrl.getOrder.bind(ctrl)));

export default router;
