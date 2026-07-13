import { Request, Response } from "express";
import { z } from "zod";
import { CategoryService } from "../services/CategoryService";
import { sendSuccess } from "../utils/response";

const categoryService = new CategoryService();

const createCategorySchema = z.object({
  name: z.string().min(1).max(100),
  imageUrl: z.string().url().optional(),
  isActive: z.boolean().optional(),
});

const updateCategorySchema = createCategorySchema.partial();

export class CategoryController {
  async getAll(_req: Request, res: Response): Promise<void> {
    const categories = await categoryService.getAll();
    sendSuccess(res, categories, "Categories retrieved");
  }

  async adminGetAll(_req: Request, res: Response): Promise<void> {
    const categories = await categoryService.getAllAdmin();
    sendSuccess(res, categories, "Categories retrieved");
  }

  async create(req: Request, res: Response): Promise<void> {
    const parsed = createCategorySchema.parse(req.body);
    const category = await categoryService.create(parsed);
    sendSuccess(res, category, "Category created", 201);
  }

  async update(req: Request, res: Response): Promise<void> {
    const parsed = updateCategorySchema.parse(req.body);
    const category = await categoryService.update(req.params["id"]!, parsed);
    sendSuccess(res, category, "Category updated");
  }

  async delete(req: Request, res: Response): Promise<void> {
    await categoryService.delete(req.params["id"]!);
    sendSuccess(res, null, "Category deleted");
  }
}
