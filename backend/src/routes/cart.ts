import { Router } from "express";
import { CartController } from "../controllers/CartController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new CartController();

router.use(authenticate);

router.get("/", asyncHandler(ctrl.getCart.bind(ctrl)));
router.post("/items", asyncHandler(ctrl.addItem.bind(ctrl)));
router.patch("/items/:itemId", asyncHandler(ctrl.updateItem.bind(ctrl)));
router.delete("/items/:itemId", asyncHandler(ctrl.removeItem.bind(ctrl)));
router.delete("/", asyncHandler(ctrl.clearCart.bind(ctrl)));

export default router;
