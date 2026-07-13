import { Prisma, PrismaClient } from "@prisma/client";
import { Pool } from "pg";
import { PrismaPg } from "@prisma/adapter-pg";
import { env } from "./env";
import { logger } from "./logger";

// Prisma's Decimal type calls .toJSON() which returns a string by default.
// Override it once at startup so every JSON response sends a JS number instead.
(Prisma.Decimal.prototype as unknown as { toJSON: () => number }).toJSON = function () {
  return Number(this);
};

declare global {
  // eslint-disable-next-line no-var
  var __prisma: PrismaClient | undefined;
}

function createPrismaClient(): PrismaClient {
  // Prisma 7: datasourceUrl is not available in the constructor when prisma.config.ts
  // is present — it's typed as never. Override DATABASE_URL for test environments instead.
  if (env.NODE_ENV === "test" && env.DATABASE_URL_TEST) {
    process.env.DATABASE_URL = env.DATABASE_URL_TEST;
  }

  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("DATABASE_URL is not set");
  }
  const pool = new Pool({ connectionString });
  const adapter = new PrismaPg(pool);

  return new PrismaClient({
    adapter,
    log:
      env.NODE_ENV === "development"
        ? ["query", "info", "warn", "error"]
        : ["warn", "error"],
  });
}

// Prevent multiple Prisma clients in development hot-reload
export const prisma: PrismaClient = global.__prisma ?? createPrismaClient();

if (env.NODE_ENV !== "production") {
  global.__prisma = prisma;
}

export async function connectDatabase(): Promise<void> {
  try {
    await prisma.$connect();
    logger.info("✅ Connected to PostgreSQL via Prisma");
  } catch (error) {
    logger.error("❌ Failed to connect to PostgreSQL:", error);
    process.exit(1);
  }
}

export async function disconnectDatabase(): Promise<void> {
  await prisma.$disconnect();
  logger.info("PostgreSQL connection closed");
}
