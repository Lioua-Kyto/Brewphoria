import { Request, Response } from "express";
import { NotificationService } from "../services/NotificationService";
import { sendSuccess } from "../utils/response";
import { paginationSchema } from "../utils/pagination";

const notifService = new NotificationService();

export class NotificationController {
  async getNotifications(req: Request, res: Response): Promise<void> {
    const query = paginationSchema.parse(req.query);
    const result = await notifService.getNotifications(
      req.user!.id,
      query.page,
      query.limit,
    );
    sendSuccess(res, result.data, "Notifications retrieved", 200, result.meta);
  }

  async markRead(req: Request, res: Response): Promise<void> {
    const notif = await notifService.markRead(req.user!.id, req.params["id"]!);
    sendSuccess(res, notif, "Notification marked as read");
  }

  async markAllRead(req: Request, res: Response): Promise<void> {
    await notifService.markAllRead(req.user!.id);
    sendSuccess(res, null, "All notifications marked as read");
  }
}
