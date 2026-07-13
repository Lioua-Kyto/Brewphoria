import "./config/env";
import cron from "node-cron";
import { LoyaltyService } from "./services/LoyaltyService";
import { NotificationService } from "./services/NotificationService";
import { prisma } from "./config/database";
import { logger } from "./config/logger";

const loyaltyService = new LoyaltyService();
const notifService = new NotificationService();

// Run daily at midnight: expire points and notify affected users
cron.schedule("0 0 * * *", async () => {
  logger.info("Running loyalty points expiry cron...");

  try {
    // Find accounts with expiring points in the next 7 days
    const expiringTx = await prisma.loyaltyTransaction.findMany({
      where: {
        type: "EARNED",
        expiresAt: {
          gte: new Date(),
          lte: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        },
      },
      include: { account: { include: { user: true } } },
    });

    const notifiedUsers = new Set<string>();
    for (const tx of expiringTx) {
      if (!notifiedUsers.has(tx.account.userId)) {
        await notifService.sendToUser(
          tx.account.userId,
          "POINTS_EXPIRING",
          "Points Expiring Soon ⏰",
          `You have loyalty points expiring within 7 days. Use them before they're gone!`,
          { points: tx.points, expiresAt: tx.expiresAt?.toISOString() },
        );
        notifiedUsers.add(tx.account.userId);
      }
    }

    // Expire overdue points
    await loyaltyService.expirePoints();

    logger.info("Loyalty points expiry cron completed");
  } catch (error) {
    logger.error("Loyalty cron failed:", error);
  }
});

logger.info("Cron jobs registered");
