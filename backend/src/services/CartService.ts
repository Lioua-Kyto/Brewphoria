import { CartRepository, CartWithItems } from "../repositories/CartRepository";
import { ProductRepository } from "../repositories/ProductRepository";
import { ModifierRepository } from "../repositories/ModifierRepository";
import { NotFoundError, BadRequestError } from "../utils/errors";
import { Prisma } from "@prisma/client";

const cartRepo = new CartRepository();
const productRepo = new ProductRepository();
const modifierRepo = new ModifierRepository();

interface ModifierSnapshot {
  groupId: string;
  groupName: string;
  optionId: string;
  label: string;
  priceDelta: number;
}

/** Stable identity for a line's modifier selection (sorted option ids). */
function signatureOf(modifiers: unknown): string {
  if (!Array.isArray(modifiers)) return "";
  return modifiers
    .map((m) => (m as { optionId?: string }).optionId ?? "")
    .sort()
    .join(",");
}

export class CartService {
  async getCart(userId: string): Promise<CartWithItems> {
    return cartRepo.findOrCreate(userId);
  }

  async addItem(
    userId: string,
    productId: string,
    quantity: number,
    optionIds: string[] = [],
  ): Promise<CartWithItems> {
    const product = await productRepo.findById(productId);
    if (!product || !product.isActive) throw new NotFoundError("Product");

    // Validate & price the selected modifiers against the product's category.
    const options = await modifierRepo.findOptionsByIds(optionIds);
    if (options.length !== optionIds.length) {
      throw new BadRequestError("Invalid modifier selection");
    }
    const seenGroups = new Set<string>();
    for (const opt of options) {
      if (opt.group.categoryId !== product.categoryId) {
        throw new BadRequestError("Modifier not available for this product");
      }
      if (opt.group.selectionType === "SINGLE" && seenGroups.has(opt.groupId)) {
        throw new BadRequestError(
          `Only one option allowed for ${opt.group.name}`,
        );
      }
      seenGroups.add(opt.groupId);
    }

    const deltas = options.reduce((s, o) => s + Number(o.priceDelta), 0);
    const unitPrice = Number(product.price) + deltas;

    const snapshot: ModifierSnapshot[] = options
      .slice()
      .sort(
        (a, b) =>
          a.group.sortOrder - b.group.sortOrder || a.sortOrder - b.sortOrder,
      )
      .map((o) => ({
        groupId: o.groupId,
        groupName: o.group.name,
        optionId: o.id,
        label: o.label,
        priceDelta: Number(o.priceDelta),
      }));
    const signature = optionIds.slice().sort().join(",");

    const cart = await cartRepo.findOrCreate(userId);
    const existing = cart.items.find(
      (i) => i.productId === productId && signatureOf(i.modifiers) === signature,
    );

    const newQty = (existing?.quantity ?? 0) + quantity;
    if (product.stock < newQty) {
      throw new BadRequestError(
        `Only ${product.stock} units available in stock`,
      );
    }

    if (existing) {
      await cartRepo.updateItemQuantity(existing.id, newQty);
    } else {
      await cartRepo.createItem(
        cart.id,
        productId,
        quantity,
        unitPrice,
        snapshot as unknown as Prisma.InputJsonValue,
      );
    }
    return cartRepo.findOrCreate(userId);
  }

  async updateItem(
    userId: string,
    itemId: string,
    quantity: number,
  ): Promise<CartWithItems> {
    const cart = await cartRepo.findByUserId(userId);
    const item = cart?.items.find((i) => i.id === itemId);
    if (!cart || !item) throw new NotFoundError("Cart item");
    if (item.product.stock < quantity) {
      throw new BadRequestError(
        `Only ${item.product.stock} units available in stock`,
      );
    }
    await cartRepo.updateItemQuantity(itemId, quantity);
    return cartRepo.findOrCreate(userId);
  }

  async removeItem(userId: string, itemId: string): Promise<CartWithItems> {
    const cart = await cartRepo.findByUserId(userId);
    const item = cart?.items.find((i) => i.id === itemId);
    if (!cart || !item) throw new NotFoundError("Cart item");
    await cartRepo.removeItem(itemId);
    return cartRepo.findOrCreate(userId);
  }

  async clearCart(userId: string): Promise<void> {
    const cart = await cartRepo.findByUserId(userId);
    if (cart) await cartRepo.clearCart(cart.id);
  }
}
