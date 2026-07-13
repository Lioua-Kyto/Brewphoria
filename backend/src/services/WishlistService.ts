import {
  WishlistRepository,
  WishlistWithProduct,
} from "../repositories/WishlistRepository";
import { ProductRepository } from "../repositories/ProductRepository";
import { NotFoundError } from "../utils/errors";

const wishlistRepo = new WishlistRepository();
const productRepo = new ProductRepository();

export class WishlistService {
  async getWishlist(userId: string): Promise<WishlistWithProduct[]> {
    return wishlistRepo.findByUser(userId);
  }

  async add(userId: string, productId: string): Promise<WishlistWithProduct[]> {
    const product = await productRepo.findById(productId);
    if (!product || !product.isActive) throw new NotFoundError("Product");
    await wishlistRepo.add(userId, productId);
    return wishlistRepo.findByUser(userId);
  }

  async remove(
    userId: string,
    productId: string,
  ): Promise<WishlistWithProduct[]> {
    await wishlistRepo.remove(userId, productId);
    return wishlistRepo.findByUser(userId);
  }
}
