import { prisma } from "../config/database";
import { redis } from "../config/redis";

beforeAll(async () => {
  await prisma.$connect();
});

afterAll(async () => {
  await prisma.$disconnect();
  try {
    await redis.disconnect();
  } catch {
    // redis may already be disconnected
  }
});
