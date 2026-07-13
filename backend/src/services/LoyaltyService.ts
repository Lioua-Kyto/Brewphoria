import { LoyaltyAccount, LoyaltyTransaction } from "@prisma/client";
import { LoyaltyRepository } from "../repositories/LoyaltyRepository";
import { NotFoundError, BadRequestError } from "../utils/errors";
import { calculateLoyaltyTier, pointsToDiscount } from "../utils/utils";
import { buildPaginatedResult, PaginatedResult } from "../utils/pagination";

const loyaltyRepo = new LoyaltyRepository();

export class LoyaltyService {
  async getAccount(
    userId: string,
  ): Promise<LoyaltyAccount & { transactions: LoyaltyTransaction[] }> {
    const account = await loyaltyRepo.findByUserId(userId);
    if (!account) throw new NotFoundError("Loyalty account");
    return account;
  }

  async validateRedemption(
    userId: string,
    pointsToRedeem: number,
  ): Promise<{ discountAmount: number; validPoints: number }> {
    const account = await loyaltyRepo.findAccountByUserId(userId);
    if (!account) throw new NotFoundError("Loyalty account");
    if (pointsToRedeem <= 0)
      throw new BadRequestError("Points to redeem must be positive");
    if (pointsToRedeem > account.currentPoints) {
      throw new BadRequestError(
        `Insufficient points. You have ${account.currentPoints} points available.`,
      );
    }
    const discountAmount = pointsToDiscount(pointsToRedeem);
    return { discountAmount, validPoints: pointsToRedeem };
  }

  async getTransactionHistory(
    userId: string,
    page: number,
    limit: number,
  ): Promise<PaginatedResult<LoyaltyTransaction>> {
    const { data, total } = await loyaltyRepo.getTransactionHistory(
      userId,
      page,
      limit,
    );
    return buildPaginatedResult(data, total, page, limit);
  }

  async expirePoints(): Promise<void> {
    const expired = await loyaltyRepo.findExpiredTransactions();
    if (expired.length === 0) return;

    const grouped = expired.reduce<
      Record<
        string,
        { accountId: string; totalPoints: number; account: LoyaltyAccount }
      >
    >((acc, tx) => {
      if (!acc[tx.accountId]) {
        acc[tx.accountId] = {
          accountId: tx.accountId,
          totalPoints: 0,
          account: tx.account,
        };
      }
      acc[tx.accountId].totalPoints += tx.points;
      return acc;
    }, {});

    for (const { accountId, totalPoints, account } of Object.values(grouped)) {
      const newPoints = Math.max(0, account.currentPoints - totalPoints);
      const newTier = calculateLoyaltyTier(account.lifetimePoints);

      await loyaltyRepo.updatePoints(accountId, {
        currentPoints: newPoints,
        lifetimePoints: account.lifetimePoints,
        tier: newTier,
      });

      await loyaltyRepo.createTransaction({
        accountId,
        type: "EXPIRED",
        points: -totalPoints,
        description: `${totalPoints} points expired`,
      });
    }
  }
}
