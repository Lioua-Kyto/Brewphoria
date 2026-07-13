import { Request, Response } from "express";
import { z } from "zod";
import { WishlistService } from "../services/WishlistService";
import { sendSuccess } from "../utils/response";

const wishlistService = new WishlistService();

const addSchema = z.object({
  productId: z.string().cuid(),
});

export class WishlistController {
  async list(req: Request, res: Response): Promise<void> {
    const items = await wishlistService.getWishlist(req.user!.id);
    sendSuccess(res, items, "Wishlist retrieved");
  }

  async add(req: Request, res: Response): Promise<void> {
    const parsed = addSchema.parse(req.body);
    const items = await wishlistService.add(req.user!.id, parsed.productId);
    sendSuccess(res, items, "Added to wishlist", 201);
  }

  async remove(req: Request, res: Response): Promise<void> {
    const items = await wishlistService.remove(
      req.user!.id,
      req.params["productId"]!,
    );
    sendSuccess(res, items, "Removed from wishlist");
  }
}
