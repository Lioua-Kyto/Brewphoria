import { Request, Response } from "express";
import { AdminService } from "../services/AdminService";
import { NotificationService } from "../services/NotificationService";
import { sendSuccess } from "../utils/response";
import { paginationSchema } from "../utils/pagination";

const adminService = new AdminService();
const notifService = new NotificationService();

export class AdminController {
  async getDashboard(_req: Request, res: Response): Promise<void> {
    const stats = await adminService.getDashboardStats();
    sendSuccess(res, stats, "Dashboard stats retrieved");
  }

  async getNotifications(req: Request, res: Response): Promise<void> {
    const query = paginationSchema.parse(req.query);
    const result = await notifService.getNotifications(
      req.user!.id,
      query.page,
      query.limit,
    );
    sendSuccess(
      res,
      result.data,
      "Admin notifications retrieved",
      200,
      result.meta,
    );
  }
}
