import { Request, Response } from "express";
import { z } from "zod";
import { AuthService } from "../services/AuthService";
import { sendSuccess } from "../utils/response";
import { ValidationError } from "../utils/errors";

const authService = new AuthService();

const loginSchema = z.object({
  idToken: z.string().min(1, "Firebase ID token is required"),
});

const fcmTokenSchema = z.object({
  fcmToken: z.string().min(1, "FCM token is required"),
});

export class AuthController {
  async login(req: Request, res: Response): Promise<void> {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) throw new ValidationError("Validation failed");

    const { user, loyaltySummary } = await authService.login(
      parsed.data.idToken,
    );
    sendSuccess(res, { user, loyaltySummary }, "Login successful");
  }

  async logout(req: Request, res: Response): Promise<void> {
    await authService.logout(req.user!.id);
    sendSuccess(res, null, "Logged out successfully");
  }

  async updateFcmToken(req: Request, res: Response): Promise<void> {
    const parsed = fcmTokenSchema.safeParse(req.body);
    if (!parsed.success) throw new ValidationError("FCM token is required");

    await authService.updateFcmToken(req.user!.id, parsed.data.fcmToken);
    sendSuccess(res, null, "FCM token updated");
  }
}
