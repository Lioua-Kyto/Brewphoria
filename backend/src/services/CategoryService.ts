import { Category } from "@prisma/client";
import { CategoryRepository } from "../repositories/CategoryRepository";
import { redis } from "../config/redis";
import { NotFoundError, ConflictError } from "../utils/errors";
import { slugify } from "../utils/utils";

const categoryRepo = new CategoryRepository();
const CACHE_KEY = "brewphoria:categories:all";
const CACHE_TTL = 600; // 10 min

export class CategoryService {
  async getAll(): Promise<Category[]> {
    const cached = await redis.get<Category[]>(CACHE_KEY);
    if (cached) return cached;

    const categories = await categoryRepo.findAll(true);
    await redis.set(CACHE_KEY, categories, CACHE_TTL);
    return categories;
  }

  async getAllAdmin(): Promise<Category[]> {
    return categoryRepo.findAll(false);
  }

  async create(data: {
    name: string;
    imageUrl?: string;
    isActive?: boolean;
  }): Promise<Category> {
    const existing = await categoryRepo.findBySlug(slugify(data.name));
    if (existing)
      throw new ConflictError("Category with that name already exists");

    const category = await categoryRepo.create({
      name: data.name,
      slug: slugify(data.name),
      imageUrl: data.imageUrl,
      isActive: data.isActive ?? true,
    });

    await redis.del(CACHE_KEY);
    return category;
  }

  async update(
    id: string,
    data: Partial<{ name: string; imageUrl: string; isActive: boolean }>,
  ): Promise<Category> {
    const existing = await categoryRepo.findById(id);
    if (!existing) throw new NotFoundError("Category");

    const updated = await categoryRepo.update(id, {
      ...data,
      ...(data.name !== undefined ? { slug: slugify(data.name) } : {}),
    });

    await redis.del(CACHE_KEY);
    return updated;
  }

  async delete(id: string): Promise<void> {
    const existing = await categoryRepo.findById(id);
    if (!existing) throw new NotFoundError("Category");
    await categoryRepo.delete(id);
    await redis.del(CACHE_KEY);
  }
}
