import { Request, Response } from "express";
import { z } from "zod";
import { ProductService } from "../services/ProductService";
import { sendSuccess } from "../utils/response";
import { paginationSchema } from "../utils/pagination";

const productService = new ProductService();

const productQuerySchema = paginationSchema.extend({
  category: z.string().optional(),
  minPrice: z.coerce.number().positive().optional(),
  maxPrice: z.coerce.number().positive().optional(),
  isFeatured: z
    .string()
    .optional()
    .transform((v) =>
      v === "true" ? true : v === "false" ? false : undefined,
    ),
  search: z.string().optional(),
  sort: z.enum(["newest", "price_asc", "price_desc", "rating"]).optional(),
});

const reviewQuerySchema = paginationSchema;

const createProductSchema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().min(1),
  price: z.coerce.number().positive(),
  categoryId: z.string().cuid(),
  stock: z.coerce.number().int().min(0),
  isFeatured: z.coerce.boolean().optional(),
  isActive: z.coerce.boolean().optional(),
  type: z.enum(["DRINK", "BEANS", "MERCH"]).optional(),
});

const updateProductSchema = createProductSchema.partial();

export class ProductController {
  async list(req: Request, res: Response): Promise<void> {
    const query = productQuerySchema.parse(req.query);
    const result = await productService.list({
      categoryId: query.category,
      minPrice: query.minPrice,
      maxPrice: query.maxPrice,
      isFeatured: query.isFeatured as boolean | undefined,
      search: query.search,
      sort: query.sort,
      page: query.page,
      limit: query.limit,
    });
    sendSuccess(res, result.data, "Products retrieved", 200, result.meta);
  }

  async getBySlug(req: Request, res: Response): Promise<void> {
    const product = await productService.getBySlug(req.params["slug"]!);
    sendSuccess(res, product, "Product retrieved");
  }

  async getReviews(req: Request, res: Response): Promise<void> {
    const query = reviewQuerySchema.parse(req.query);
    const result = await productService.getReviews(
      req.params["id"]!,
      query.page,
      query.limit,
    );
    sendSuccess(res, result.data, "Reviews retrieved", 200, result.meta);
  }

  async getReviewSummary(req: Request, res: Response): Promise<void> {
    const summary = await productService.getReviewSummary(req.params["id"]!);
    sendSuccess(res, summary, "Review summary retrieved");
  }

  async adminList(req: Request, res: Response): Promise<void> {
    const query = productQuerySchema.parse(req.query);
    const result = await productService.adminList({
      categoryId: query.category,
      minPrice: query.minPrice,
      maxPrice: query.maxPrice,
      isFeatured: query.isFeatured as boolean | undefined,
      search: query.search,
      page: query.page,
      limit: query.limit,
    });
    sendSuccess(res, result.data, "Products retrieved", 200, result.meta);
  }

  async create(req: Request, res: Response): Promise<void> {
    const parsed = createProductSchema.parse(req.body);
    const files = req.files as Express.Multer.File[] | undefined;
    const product = await productService.create(parsed, files);
    sendSuccess(res, product, "Product created", 201);
  }

  async update(req: Request, res: Response): Promise<void> {
    const parsed = updateProductSchema.parse(req.body);
    const files = req.files as Express.Multer.File[] | undefined;
    const product = await productService.update(
      req.params["id"]!,
      parsed,
      files,
    );
    sendSuccess(res, product, "Product updated");
  }

  async softDelete(req: Request, res: Response): Promise<void> {
    await productService.softDelete(req.params["id"]!);
    sendSuccess(res, null, "Product deleted");
  }
}
