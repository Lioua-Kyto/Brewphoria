import { ChatSession, ChatMessage } from "@prisma/client";
import { prisma } from "../config/database";

export class ChatRepository {
  async createSession(userId: string): Promise<ChatSession> {
    return prisma.chatSession.create({ data: { userId } });
  }

  async findSession(
    sessionId: string,
    userId: string,
  ): Promise<ChatSession | null> {
    return prisma.chatSession.findFirst({
      where: { id: sessionId, userId },
    });
  }

  async getRecentMessages(
    sessionId: string,
    limit = 10,
  ): Promise<ChatMessage[]> {
    return prisma.chatMessage.findMany({
      where: { sessionId },
      orderBy: { createdAt: "desc" },
      take: limit,
    });
  }

  async saveMessage(data: {
    sessionId: string;
    role: "user" | "assistant";
    content: string;
  }): Promise<ChatMessage> {
    return prisma.chatMessage.create({ data });
  }

  async updateSessionTimestamp(sessionId: string): Promise<void> {
    await prisma.chatSession.update({
      where: { id: sessionId },
      data: { updatedAt: new Date() },
    });
  }
}
