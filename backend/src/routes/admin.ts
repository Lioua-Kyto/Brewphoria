import { Router } from "express";
import { ProductController } from "../controllers/ProductController";
import { CategoryController } from "../controllers/CategoryController";
import { OrderController } from "../controllers/OrderController";
import { ReviewController } from "../controllers/ReviewController";
import { AdminController } from "../controllers/AdminController";
import { authenticate } from "../middleware/auth";
import { requireAdmin } from "../middleware/roleGuard";
import { asyncHandler } from "../middleware/asyncHandler";
import { upload } from "../middleware/upload";

const router = Router();

const productCtrl = new ProductController();
const categoryCtrl = new CategoryController();
const orderCtrl = new OrderController();
const reviewCtrl = new ReviewController();
const adminCtrl = new AdminController();

router.use(authenticate, requireAdmin);

// Dashboard
router.get("/dashboard", asyncHandler(adminCtrl.getDashboard.bind(adminCtrl)));
router.get(
  "/notifications",
  asyncHandler(adminCtrl.getNotifications.bind(adminCtrl)),
);

// Products
router.get("/products", asyncHandler(productCtrl.adminList.bind(productCtrl)));
router.post(
  "/products",
  upload.array("images", 5),
  asyncHandler(productCtrl.create.bind(productCtrl)),
);
router.patch(
  "/products/:id",
  upload.array("images", 5),
  asyncHandler(productCtrl.update.bind(productCtrl)),
);
router.delete(
  "/products/:id",
  asyncHandler(productCtrl.softDelete.bind(productCtrl)),
);

// Categories
router.get(
  "/categories",
  asyncHandler(categoryCtrl.adminGetAll.bind(categoryCtrl)),
);
router.post(
  "/categories",
  asyncHandler(categoryCtrl.create.bind(categoryCtrl)),
);
router.patch(
  "/categories/:id",
  asyncHandler(categoryCtrl.update.bind(categoryCtrl)),
);
router.delete(
  "/categories/:id",
  asyncHandler(categoryCtrl.delete.bind(categoryCtrl)),
);

// Orders
router.get("/orders", asyncHandler(orderCtrl.adminGetOrders.bind(orderCtrl)));
router.patch(
  "/orders/:id/status",
  asyncHandler(orderCtrl.adminUpdateStatus.bind(orderCtrl)),
);

// Reviews
router.get("/reviews", asyncHandler(reviewCtrl.adminList.bind(reviewCtrl)));
router.patch(
  "/reviews/:id/visibility",
  asyncHandler(reviewCtrl.adminUpdateVisibility.bind(reviewCtrl)),
);

export default router;
