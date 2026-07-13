import { Prisma, Category } from "@prisma/client";
import { prisma } from "../config/database";

export class CategoryRepository {
  async findAll(activeOnly = true): Promise<Category[]> {
    return prisma.category.findMany({
      where: activeOnly ? { isActive: true } : undefined,
      orderBy: { name: "asc" },
    });
  }

  async findBySlug(slug: string): Promise<Category | null> {
    return prisma.category.findUnique({ where: { slug } });
  }

  async findById(id: string): Promise<Category | null> {
    return prisma.category.findUnique({ where: { id } });
  }

  async create(data: Prisma.CategoryCreateInput): Promise<Category> {
    return prisma.category.create({ data });
  }

  async update(
    id: string,
    data: Prisma.CategoryUpdateInput,
  ): Promise<Category> {
    return prisma.category.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await prisma.category.delete({ where: { id } });
  }
}
