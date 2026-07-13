import { prisma } from "../config/database";
import { Prisma, CartItem } from "@prisma/client";

const cartInclude = {
  items: {
    include: {
      product: {
        select: {
          id: true,
          name: true,
          slug: true,
          description: true,
          price: true,
          images: true,
          stock: true,
          isActive: true,
          isFeatured: true,
          avgRating: true,
          reviewCount: true,
          categoryId: true,
          category: { select: { id: true, name: true, slug: true } },
        },
      },
    },
    orderBy: { addedAt: "asc" },
  },
} satisfies Prisma.CartInclude;

export type CartWithItems = Prisma.CartGetPayload<{ include: typeof cartInclude }>;
export type CartLine = CartWithItems["items"][number];

export class CartRepository {
  async findByUserId(userId: string): Promise<CartWithItems | null> {
    return prisma.cart.findUnique({
      where: { userId },
      include: cartInclude,
    });
  }

  async findOrCreate(userId: string): Promise<CartWithItems> {
    const existing = await this.findByUserId(userId);
    if (existing) return existing;

    await prisma.cart.create({ data: { userId } });
    return this.findByUserId(userId) as Promise<CartWithItems>;
  }

  async createItem(
    cartId: string,
    productId: string,
    quantity: number,
    unitPrice: number,
    modifiers: Prisma.InputJsonValue,
  ): Promise<CartItem> {
    return prisma.cartItem.create({
      data: { cartId, productId, quantity, unitPrice, modifiers },
    });
  }

  async updateItemQuantity(
    itemId: string,
    quantity: number,
  ): Promise<CartItem> {
    return prisma.cartItem.update({
      where: { id: itemId },
      data: { quantity },
    });
  }

  async removeItem(itemId: string): Promise<void> {
    await prisma.cartItem.delete({ where: { id: itemId } });
  }

  async clearCart(cartId: string): Promise<void> {
    await prisma.cartItem.deleteMany({ where: { cartId } });
  }

  async findItemById(itemId: string): Promise<CartItem | null> {
    return prisma.cartItem.findUnique({ where: { id: itemId } });
  }
}
