import { prisma } from "../config/database";
import { WishlistItem, Prisma } from "@prisma/client";

const productSelect = {
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
} satisfies Prisma.ProductSelect;

export type WishlistWithProduct = WishlistItem & {
  product: Prisma.ProductGetPayload<{ select: typeof productSelect }>;
};

export class WishlistRepository {
  async findByUser(userId: string): Promise<WishlistWithProduct[]> {
    return prisma.wishlistItem.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      include: { product: { select: productSelect } },
    });
  }

  async exists(userId: string, productId: string): Promise<boolean> {
    const found = await prisma.wishlistItem.findUnique({
      where: { userId_productId: { userId, productId } },
    });
    return found !== null;
  }

  async add(userId: string, productId: string): Promise<void> {
    await prisma.wishlistItem.upsert({
      where: { userId_productId: { userId, productId } },
      create: { userId, productId },
      update: {},
    });
  }

  async remove(userId: string, productId: string): Promise<void> {
    await prisma.wishlistItem.deleteMany({ where: { userId, productId } });
  }
}
