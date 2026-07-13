import { Request, Response } from "express";
import { z } from "zod";
import { ChatService } from "../services/ChatService";
import { sendSuccess } from "../utils/response";

const chatService = new ChatService();

const chatSchema = z.object({
  message: z.string().min(1).max(1000),
  sessionId: z.string().optional(),
});

export class ChatController {
  async sendMessage(req: Request, res: Response): Promise<void> {
    const parsed = chatSchema.parse(req.body);
    const result = await chatService.chat(
      req.user!.id,
      parsed.message,
      parsed.sessionId,
    );
    sendSuccess(res, result, "Message sent");
  }
}
