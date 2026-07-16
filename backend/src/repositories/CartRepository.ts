import { prisma } from "../config/database";
import { Cart, CartItem } from "@prisma/client";

export type CartWithItems = Cart & {
  items: (CartItem & {
    product: {
      id: string;
      name: string;
      slug: string;
      description: string;
      price: import("@prisma/client").Prisma.Decimal;
      images: string[];
      stock: number;
      isActive: boolean;
      isFeatured: boolean;
      avgRating: import("@prisma/client").Prisma.Decimal;
      reviewCount: number;
      categoryId: string;
      category: { id: string; name: string; slug: string } | null;
    };
  })[];
};

export class CartRepository {
  async findByUserId(userId: string): Promise<CartWithItems | null> {
    return prisma.cart.findUnique({
      where: { userId },
      include: {
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
      },
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
    unitPrice: number | import("@prisma/client").Prisma.Decimal,
    modifiers: import("@prisma/client").Prisma.InputJsonValue = [],
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

  async findItem(cartId: string, productId: string): Promise<CartItem | null> {
    return prisma.cartItem.findFirst({
      where: { cartId, productId },
    });
  }
}
