import "dotenv/config";
import "./config/env"; // Validate env at startup
import express, { Application, Request, Response } from "express";
import path from "path";
import helmet from "helmet";
import cors from "cors";
import morgan from "morgan";
import { env } from "./config/env";
import { logger } from "./config/logger";
import { globalRateLimiter } from "./middleware/rateLimiter";
import { errorHandler } from "./middleware/errorHandler";
import { UPLOADS_DIR } from "./middleware/upload";
import v1Router from "./routes/index";

const app: Application = express();

// ── Security middleware ─────────────────────────────────────────────────────
app.use(helmet());
app.use(
  cors({
    origin: env.ALLOWED_ORIGINS.split(",").map((o) => o.trim()),
    credentials: true,
  }),
);
app.use(globalRateLimiter);

// ── Logging ─────────────────────────────────────────────────────────────────
app.use(
  morgan("combined", {
    stream: { write: (message) => logger.http(message.trim()) },
    skip: (req) => req.path === "/health",
  }),
);

// ── Body parsing ─────────────────────────────────────────────────────────────
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// ── Static file serving (uploaded images) ────────────────────────────────────
app.use("/uploads", express.static(path.join(UPLOADS_DIR)));

// ── Health check ─────────────────────────────────────────────────────────────
app.get("/health", (_req: Request, res: Response) => {
  res.json({
    success: true,
    data: { status: "ok", timestamp: new Date().toISOString() },
    message: "BrewPhoria API is running",
  });
});

// ── API routes ────────────────────────────────────────────────────────────────
app.use("/api/v1", v1Router);

// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((_req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: {
      code: "NOT_FOUND",
      message: "The requested endpoint does not exist",
    },
  });
});

// ── Global error handler ─────────────────────────────────────────────────────
app.use(errorHandler);

export default app;
