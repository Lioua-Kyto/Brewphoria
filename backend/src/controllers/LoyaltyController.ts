import { Request, Response } from "express";
import { z } from "zod";
import { LoyaltyService } from "../services/LoyaltyService";
import { sendSuccess } from "../utils/response";
import { paginationSchema } from "../utils/pagination";

const loyaltyService = new LoyaltyService();

const redeemSchema = z.object({
  pointsToRedeem: z.number().int().positive(),
});

export class LoyaltyController {
  async getAccount(req: Request, res: Response): Promise<void> {
    const account = await loyaltyService.getAccount(req.user!.id);
    sendSuccess(res, account, "Loyalty account retrieved");
  }

  async redeem(req: Request, res: Response): Promise<void> {
    const parsed = redeemSchema.parse(req.body);
    const result = await loyaltyService.validateRedemption(
      req.user!.id,
      parsed.pointsToRedeem,
    );
    sendSuccess(res, result, "Redemption validated");
  }

  async getHistory(req: Request, res: Response): Promise<void> {
    const query = paginationSchema.parse(req.query);
    const result = await loyaltyService.getTransactionHistory(
      req.user!.id,
      query.page,
      query.limit,
    );
    sendSuccess(
      res,
      result.data,
      "Transaction history retrieved",
      200,
      result.meta,
    );
  }
}
