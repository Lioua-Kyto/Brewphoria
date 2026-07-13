import { Request, Response } from "express";
import { z } from "zod";
import { OrderService } from "../services/OrderService";
import { sendSuccess } from "../utils/response";
import { paginationSchema } from "../utils/pagination";

const orderService = new OrderService();

const checkoutSchema = z.object({
  addressId: z.string().cuid(),
  pointsToRedeem: z.number().int().min(0).default(0),
  paymentMethod: z.enum(["COD", "BANK_TRANSFER"]).default("COD"),
  notes: z.string().max(500).optional(),
  tip: z.number().min(0).max(1000).default(0),
});

const adminOrderQuerySchema = paginationSchema.extend({
  status: z
    .enum([
      "PENDING",
      "CONFIRMED",
      "PREPARING",
      "OUT_FOR_DELIVERY",
      "DELIVERED",
      "CANCELLED",
      "REFUNDED",
    ])
    .optional(),
  dateFrom: z
    .string()
    .optional()
    .transform((v) => (v ? new Date(v) : undefined)),
  dateTo: z
    .string()
    .optional()
    .transform((v) => (v ? new Date(v) : undefined)),
});

const updateStatusSchema = z.object({
  status: z.enum([
    "PENDING",
    "CONFIRMED",
    "PREPARING",
    "OUT_FOR_DELIVERY",
    "DELIVERED",
    "CANCELLED",
    "REFUNDED",
  ]),
});

export class OrderController {
  async checkout(req: Request, res: Response): Promise<void> {
    const parsed = checkoutSchema.parse(req.body);
    const order = await orderService.checkout(
      req.user!.id,
      parsed.addressId,
      parsed.pointsToRedeem,
      parsed.paymentMethod,
      parsed.notes,
      parsed.tip,
    );
    sendSuccess(res, order, "Order placed successfully", 201);
  }

  async getOrders(req: Request, res: Response): Promise<void> {
    const query = paginationSchema.parse(req.query);
    const result = await orderService.getOrders(
      req.user!.id,
      query.page,
      query.limit,
    );
    sendSuccess(res, result.data, "Orders retrieved", 200, result.meta);
  }

  async getOrder(req: Request, res: Response): Promise<void> {
    const order = await orderService.getOrder(req.user!.id, req.params["id"]!);
    sendSuccess(res, order, "Order retrieved");
  }

  async adminGetOrders(req: Request, res: Response): Promise<void> {
    const query = adminOrderQuerySchema.parse(req.query);
    const result = await orderService.adminGetOrders(query);
    sendSuccess(res, result.data, "Orders retrieved", 200, result.meta);
  }

  async adminUpdateStatus(req: Request, res: Response): Promise<void> {
    const parsed = updateStatusSchema.parse(req.body);
    const order = await orderService.adminUpdateStatus(
      req.params["id"]!,
      parsed.status,
    );
    sendSuccess(res, order, "Order status updated");
  }
}
