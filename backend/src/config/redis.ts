import Redis from "ioredis";
import { env } from "./env";
import { logger } from "./logger";

class RedisService {
  private client: Redis;

  constructor() {
    this.client = new Redis(env.REDIS_URL, {
      lazyConnect: true,
      retryStrategy: (times: number) => Math.min(times * 50, 2000),
    });

    this.client.on("connect", () => logger.info("✅ Connected to Redis"));
    this.client.on("error", (err: Error) => logger.error("Redis error:", err));
  }

  async connect(): Promise<void> {
    await this.client.connect();
  }

  async get<T>(key: string): Promise<T | null> {
    const value = await this.client.get(key);
    if (value === null) return null;
    return JSON.parse(value) as T;
  }

  async set(key: string, value: unknown, ttlSeconds?: number): Promise<void> {
    const serialized = JSON.stringify(value);
    if (ttlSeconds !== undefined) {
      await this.client.setex(key, ttlSeconds, serialized);
    } else {
      await this.client.set(key, serialized);
    }
  }

  async del(key: string): Promise<void> {
    await this.client.del(key);
  }

  async invalidatePattern(pattern: string): Promise<void> {
    const keys = await this.client.keys(pattern);
    if (keys.length > 0) {
      await this.client.del(...keys);
      logger.debug(
        `Invalidated ${keys.length} Redis keys matching: ${pattern}`,
      );
    }
  }

  async disconnect(): Promise<void> {
    await this.client.quit();
    logger.info("Redis connection closed");
  }

  getClient(): Redis {
    return this.client;
  }
}

export const redis = new RedisService();
