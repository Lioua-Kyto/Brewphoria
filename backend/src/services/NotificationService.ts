import { Notification, NotificationType } from "@prisma/client";
import { NotificationRepository } from "../repositories/NotificationRepository";
import { firebaseMessaging } from "../config/firebase";
import { UserRepository } from "../repositories/UserRepository";
import { logger } from "../config/logger";
import { NotFoundError, ForbiddenError } from "../utils/errors";
import { buildPaginatedResult, PaginatedResult } from "../utils/pagination";

const notifRepo = new NotificationRepository();
const userRepo = new UserRepository();

export class NotificationService {
  async getNotifications(
    userId: string,
    page: number,
    limit: number,
  ): Promise<PaginatedResult<Notification>> {
    const { data, total } = await notifRepo.findByUser(userId, page, limit);
    return buildPaginatedResult(data, total, page, limit);
  }

  async markRead(
    userId: string,
    notificationId: string,
  ): Promise<Notification> {
    const notif = await notifRepo.findById(notificationId);
    if (!notif) throw new NotFoundError("Notification");
    if (notif.userId !== userId)
      throw new ForbiddenError("Not your notification");
    return notifRepo.markAsRead(notificationId);
  }

  async markAllRead(userId: string): Promise<void> {
    await notifRepo.markAllAsRead(userId);
  }

  async sendToUser(
    userId: string,
    type: NotificationType,
    title: string,
    body: string,
    data?: Record<string, unknown>,
  ): Promise<void> {
    await notifRepo.create({ userId, type, title, body, data });

    const user = await userRepo.findById(userId);
    if (user?.fcmToken) {
      await this.sendFcmNotification(user.fcmToken, title, body, data);
    }
  }

  async sendToAdmins(
    type: NotificationType,
    title: string,
    body: string,
    data?: Record<string, unknown>,
  ): Promise<void> {
    const admins = await userRepo.findAdmins();
    const adminNotifs = admins.map((admin) => ({
      userId: admin.id,
      type,
      title,
      body,
      data,
    }));

    if (adminNotifs.length > 0) {
      await notifRepo.createMany(adminNotifs);
    }

    const tokens = admins
      .map((a) => a.fcmToken)
      .filter((t): t is string => t !== null && t !== undefined);

    for (const token of tokens) {
      await this.sendFcmNotification(token, title, body, data);
    }
  }

  private async sendFcmNotification(
    token: string,
    title: string,
    body: string,
    data?: Record<string, unknown>,
  ): Promise<void> {
    try {
      await firebaseMessaging.send({
        token,
        notification: { title, body },
        data: data
          ? Object.fromEntries(
              Object.entries(data).map(([k, v]) => [k, String(v)]),
            )
          : undefined,
      });
    } catch (err) {
      logger.error("FCM send failed:", err);
    }
  }
}
