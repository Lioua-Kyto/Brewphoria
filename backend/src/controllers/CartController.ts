import { Request, Response } from "express";
import { z } from "zod";
import { CartService } from "../services/CartService";
import { sendSuccess } from "../utils/response";

const cartService = new CartService();

const addItemSchema = z.object({
  productId: z.string().cuid(),
  quantity: z.number().int().min(1).max(99),
  modifiers: z.array(z.string().cuid()).max(20).optional().default([]),
});

const updateItemSchema = z.object({
  quantity: z.number().int().min(1).max(99),
});

export class CartController {
  async getCart(req: Request, res: Response): Promise<void> {
    const cart = await cartService.getCart(req.user!.id);
    sendSuccess(res, cart, "Cart retrieved");
  }

  async addItem(req: Request, res: Response): Promise<void> {
    const parsed = addItemSchema.parse(req.body);
    const cart = await cartService.addItem(
      req.user!.id,
      parsed.productId,
      parsed.quantity,
      parsed.modifiers,
    );
    sendSuccess(res, cart, "Item added to cart", 201);
  }

  async updateItem(req: Request, res: Response): Promise<void> {
    const parsed = updateItemSchema.parse(req.body);
    const cart = await cartService.updateItem(
      req.user!.id,
      req.params["itemId"]!,
      parsed.quantity,
    );
    sendSuccess(res, cart, "Cart item updated");
  }

  async removeItem(req: Request, res: Response): Promise<void> {
    const cart = await cartService.removeItem(
      req.user!.id,
      req.params["itemId"]!,
    );
    sendSuccess(res, cart, "Item removed from cart");
  }

  async clearCart(req: Request, res: Response): Promise<void> {
    await cartService.clearCart(req.user!.id);
    sendSuccess(res, null, "Cart cleared");
  }
}
