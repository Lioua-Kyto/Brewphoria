import { Product } from "@prisma/client";
import {
  ProductRepository,
  ProductFilters,
} from "../repositories/ProductRepository";
import { CategoryRepository } from "../repositories/CategoryRepository";
import { ReviewRepository } from "../repositories/ReviewRepository";
import { ModifierRepository } from "../repositories/ModifierRepository";
import { redis } from "../config/redis";
import { processAndSaveImage } from "../middleware/upload";
import { NotFoundError, BadRequestError } from "../utils/errors";
import { slugify, hashQueryParams } from "../utils/utils";
import { buildPaginatedResult, PaginatedResult } from "../utils/pagination";

const productRepo = new ProductRepository();
const categoryRepo = new CategoryRepository();
const modifierRepo = new ModifierRepository();

interface ModifierOptionDto {
  id: string;
  label: string;
  priceDelta: number;
  isDefault: boolean;
}
interface ModifierGroupDto {
  id: string;
  name: string;
  selectionType: string;
  isRequired: boolean;
  sortOrder: number;
  options: ModifierOptionDto[];
}
type ProductDetail = Product & {
  category: { id: string; name: string; slug: string };
  modifierGroups: ModifierGroupDto[];
};

const PRODUCT_TTL = 300; // 5 min
const SLUG_TTL = 300;

function productListKey(params: Record<string, unknown>): string {
  return `brewphoria:products:list:${hashQueryParams(params)}`;
}

function productSlugKey(slug: string): string {
  return `brewphoria:products:slug:${slug}`;
}

export class ProductService {
  async list(
    filters: Omit<ProductFilters, "isActive"> & { page: number; limit: number },
  ): Promise<PaginatedResult<Product>> {
    const cacheKey = productListKey(filters as Record<string, unknown>);
    const cached = await redis.get<PaginatedResult<Product>>(cacheKey);
    if (cached) return cached;

    const { data, total } = await productRepo.findMany({
      ...filters,
      isActive: true,
    });
    const result = buildPaginatedResult(
      data,
      total,
      filters.page,
      filters.limit,
    );
    await redis.set(cacheKey, result, PRODUCT_TTL);
    return result;
  }

  async getBySlug(slug: string): Promise<ProductDetail> {
    const cacheKey = productSlugKey(slug);
    const cached = await redis.get<ProductDetail>(cacheKey);
    if (cached) return cached;

    const product = await productRepo.findBySlug(slug);
    if (!product || !product.isActive) throw new NotFoundError("Product");

    // MERCH products (merchandise, packaged goods, pastries) never offer
    // customization, regardless of what modifier groups happen to be attached
    // to their category — the product's own type is the source of truth, not
    // the category (a category like "Tea & Alternatives" mixes drinkable
    // items with retail packaged goods).
    const groups =
      product.type === "MERCH"
        ? []
        : await modifierRepo.findGroupsByCategory(product.categoryId);
    const modifierGroups: ModifierGroupDto[] = groups.map((g) => ({
      id: g.id,
      name: g.name,
      selectionType: g.selectionType,
      isRequired: g.isRequired,
      sortOrder: g.sortOrder,
      options: g.options.map((o) => ({
        id: o.id,
        label: o.label,
        priceDelta: Number(o.priceDelta),
        isDefault: o.isDefault,
      })),
    }));

    const result: ProductDetail = { ...product, modifierGroups };
    await redis.set(cacheKey, result, SLUG_TTL);
    return result;
  }

  async getReviews(productId: string, page: number, limit: number) {
    const product = await productRepo.findById(productId);
    if (!product) throw new NotFoundError("Product");

    const reviewRepo = new ReviewRepository();
    const { data, total } = await reviewRepo.findMany({
      productId,
      isVisible: true,
      page,
      limit,
    });
    return buildPaginatedResult(data, total, page, limit);
  }

  async getReviewSummary(productId: string) {
    const product = await productRepo.findById(productId);
    if (!product) throw new NotFoundError("Product");

    const reviewRepo = new ReviewRepository();
    return reviewRepo.summary(productId);
  }

  // Admin
  async adminList(filters: ProductFilters): Promise<PaginatedResult<Product>> {
    const { data, total } = await productRepo.findMany(filters);
    return buildPaginatedResult(data, total, filters.page, filters.limit);
  }

  async create(
    data: {
      name: string;
      description: string;
      price: number;
      categoryId: string;
      stock: number;
      isFeatured?: boolean;
      isActive?: boolean;
      type?: "DRINK" | "BEANS" | "MERCH";
    },
    imageFiles?: Express.Multer.File[],
  ): Promise<Product> {
    const category = await categoryRepo.findById(data.categoryId);
    if (!category) throw new NotFoundError("Category");

    const slug = slugify(data.name);
    const existingSlug = await productRepo.findBySlug(slug);
    if (existingSlug)
      throw new BadRequestError("A product with that name already exists");

    const imageUrls: string[] = [];
    if (imageFiles && imageFiles.length > 0) {
      for (const file of imageFiles) {
        const url = await processAndSaveImage(file.buffer);
        imageUrls.push(url);
      }
    }

    const product = await productRepo.create({
      name: data.name,
      slug,
      description: data.description,
      price: data.price,
      category: { connect: { id: data.categoryId } },
      images: imageUrls,
      stock: data.stock,
      isFeatured: data.isFeatured ?? false,
      isActive: data.isActive ?? true,
      ...(data.type ? { type: data.type } : {}),
    });

    await redis.invalidatePattern("brewphoria:products:list:*");
    return product;
  }

  async update(
    id: string,
    data: Partial<{
      name: string;
      description: string;
      price: number;
      categoryId: string;
      stock: number;
      isFeatured: boolean;
      isActive: boolean;
      type: "DRINK" | "BEANS" | "MERCH";
    }>,
    imageFiles?: Express.Multer.File[],
  ): Promise<Product> {
    const existing = await productRepo.findById(id);
    if (!existing) throw new NotFoundError("Product");

    if (data.categoryId) {
      const cat = await categoryRepo.findById(data.categoryId);
      if (!cat) throw new NotFoundError("Category");
    }

    const imageUrls: string[] = [];
    if (imageFiles && imageFiles.length > 0) {
      for (const file of imageFiles) {
        const url = await processAndSaveImage(file.buffer);
        imageUrls.push(url);
      }
    }

    const product = await productRepo.update(id, {
      ...data,
      ...(data.price !== undefined ? { price: data.price } : {}),
      ...(data.categoryId !== undefined
        ? { category: { connect: { id: data.categoryId } } }
        : {}),
      ...(imageUrls.length > 0 ? { images: imageUrls } : {}),
      ...(data.name !== undefined ? { slug: slugify(data.name) } : {}),
    });

    await redis.invalidatePattern("brewphoria:products:list:*");
    await redis.del(productSlugKey(existing.slug));
    return product;
  }

  async softDelete(id: string): Promise<void> {
    const existing = await productRepo.findById(id);
    if (!existing) throw new NotFoundError("Product");
    await productRepo.softDelete(id);
    await redis.invalidatePattern("brewphoria:products:list:*");
    await redis.del(productSlugKey(existing.slug));
  }
}
