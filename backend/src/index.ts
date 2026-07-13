import "./config/env"; // Validate env first
import app from "./app";
import { connectDatabase, disconnectDatabase } from "./config/database";
import { redis } from "./config/redis";
import { env } from "./config/env";
import { logger } from "./config/logger";
import "./config/firebase";

const PORT = env.PORT;

async function startServer(): Promise<void> {
  try {
    await connectDatabase();
    await redis.connect();

    const server = app.listen(PORT, () => {
      logger.info(
        `🚀 BrewPhoria API running on port ${PORT} [${env.NODE_ENV}]`,
      );
    });

    // Graceful shutdown
    const shutdown = async (signal: string): Promise<void> => {
      logger.info(`${signal} received. Shutting down gracefully...`);
      server.close(async () => {
        await disconnectDatabase();
        await redis.disconnect();
        logger.info("Server closed. Bye!");
        process.exit(0);
      });
    };

    process.on("SIGTERM", () => void shutdown("SIGTERM"));
    process.on("SIGINT", () => void shutdown("SIGINT"));
  } catch (error) {
    logger.error("Failed to start server:", error);
    process.exit(1);
  }
}

void startServer();
