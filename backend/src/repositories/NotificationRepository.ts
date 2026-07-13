import { Notification, NotificationType, Prisma } from "@prisma/client";
import { prisma } from "../config/database";

type NotifInput = {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, unknown>;
};

export class NotificationRepository {
  async create(data: NotifInput): Promise<Notification> {
    return prisma.notification.create({
      data: {
        userId: data.userId,
        type: data.type,
        title: data.title,
        body: data.body,
        ...(data.data !== undefined
          ? { data: data.data as Prisma.InputJsonValue }
          : {}),
      },
    });
  }

  async createMany(notifications: NotifInput[]): Promise<void> {
    await prisma.notification.createMany({
      data: notifications.map((n) => ({
        userId: n.userId,
        type: n.type,
        title: n.title,
        body: n.body,
        ...(n.data !== undefined
          ? { data: n.data as Prisma.InputJsonValue }
          : {}),
      })),
    });
  }

  async findByUser(
    userId: string,
    page: number,
    limit: number,
  ): Promise<{ data: Notification[]; total: number }> {
    const skip = (page - 1) * limit;
    const [data, total] = await prisma.$transaction([
      prisma.notification.findMany({
        where: { userId },
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      prisma.notification.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async findById(id: string): Promise<Notification | null> {
    return prisma.notification.findUnique({ where: { id } });
  }

  async markAsRead(id: string): Promise<Notification> {
    return prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
  }

  async markAllAsRead(userId: string): Promise<void> {
    await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
  }
}
