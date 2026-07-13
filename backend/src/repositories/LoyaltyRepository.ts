import {
  LoyaltyAccount,
  LoyaltyTransaction,
  LoyaltyTier,
  LoyaltyTransactionType,
} from "@prisma/client";
import { prisma } from "../config/database";

export type LoyaltyTransactionWithAccount = LoyaltyTransaction & {
  account: LoyaltyAccount;
};

export class LoyaltyRepository {
  async findByUserId(
    userId: string,
  ): Promise<(LoyaltyAccount & { transactions: LoyaltyTransaction[] }) | null> {
    return prisma.loyaltyAccount.findUnique({
      where: { userId },
      include: {
        transactions: {
          orderBy: { createdAt: "desc" },
          take: 50,
        },
      },
    });
  }

  async findAccountByUserId(userId: string): Promise<LoyaltyAccount | null> {
    return prisma.loyaltyAccount.findUnique({ where: { userId } });
  }

  async createTransaction(data: {
    accountId: string;
    orderId?: string;
    type: LoyaltyTransactionType;
    points: number;
    description: string;
    expiresAt?: Date;
  }): Promise<LoyaltyTransaction> {
    return prisma.loyaltyTransaction.create({ data });
  }

  async updatePoints(
    accountId: string,
    data: {
      currentPoints: number;
      lifetimePoints: number;
      tier: LoyaltyTier;
    },
  ): Promise<LoyaltyAccount> {
    return prisma.loyaltyAccount.update({ where: { id: accountId }, data });
  }

  async findExpiredTransactions(): Promise<LoyaltyTransactionWithAccount[]> {
    return prisma.loyaltyTransaction.findMany({
      where: {
        type: "EARNED",
        expiresAt: { lte: new Date() },
      },
      include: { account: true },
    });
  }

  async findActiveTransactionsByAccount(
    accountId: string,
  ): Promise<LoyaltyTransaction[]> {
    return prisma.loyaltyTransaction.findMany({
      where: {
        accountId,
        type: "EARNED",
        expiresAt: { gt: new Date() },
      },
      orderBy: { expiresAt: "asc" },
    });
  }

  async getTransactionHistory(
    userId: string,
    page: number,
    limit: number,
  ): Promise<{ data: LoyaltyTransaction[]; total: number }> {
    const account = await prisma.loyaltyAccount.findUnique({
      where: { userId },
      select: { id: true },
    });
    if (!account) return { data: [], total: 0 };

    const skip = (page - 1) * limit;
    const [data, total] = await prisma.$transaction([
      prisma.loyaltyTransaction.findMany({
        where: { accountId: account.id },
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      prisma.loyaltyTransaction.count({ where: { accountId: account.id } }),
    ]);

    return { data, total };
  }
}
