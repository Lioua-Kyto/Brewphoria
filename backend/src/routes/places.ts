import { Router } from "express";
import { PlacesController } from "../controllers/PlacesController";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/asyncHandler";

const router = Router();
const ctrl = new PlacesController();

router.use(authenticate);

router.get("/autocomplete", asyncHandler(ctrl.autocomplete.bind(ctrl)));
router.get("/details/:placeId", asyncHandler(ctrl.details.bind(ctrl)));

export default router;
