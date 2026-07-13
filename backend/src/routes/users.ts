import { Router } from "express";
import { UserController } from "../controllers/UserController";
import { WishlistController } from "../controllers/WishlistController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new UserController();
const wishlist = new WishlistController();

router.use(authenticate);

router.get("/me", asyncHandler(ctrl.getMe.bind(ctrl)));
router.patch("/me", asyncHandler(ctrl.updateMe.bind(ctrl)));
router.get("/me/addresses", asyncHandler(ctrl.getAddresses.bind(ctrl)));
router.post("/me/addresses", asyncHandler(ctrl.addAddress.bind(ctrl)));
router.patch("/me/addresses/:id", asyncHandler(ctrl.updateAddress.bind(ctrl)));
router.delete("/me/addresses/:id", asyncHandler(ctrl.deleteAddress.bind(ctrl)));

router.get("/me/wishlist", asyncHandler(wishlist.list.bind(wishlist)));
router.post("/me/wishlist", asyncHandler(wishlist.add.bind(wishlist)));
router.delete(
  "/me/wishlist/:productId",
  asyncHandler(wishlist.remove.bind(wishlist)),
);

export default router;
