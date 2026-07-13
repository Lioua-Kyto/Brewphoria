import { Request, Response, NextFunction } from "express";
import { ZodError } from "zod";
import { Prisma } from "@prisma/client";
import {
  AppError,
  NotFoundError,
  ConflictError,
  ValidationError,
} from "../utils/errors";
import { logger } from "../config/logger";
import { env } from "../config/env";

export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  if (res.headersSent) return;

  // Zod validation errors
  if (err instanceof ZodError) {
    const fields = err.errors.reduce<Record<string, string[]>>((acc, issue) => {
      const key = issue.path.join(".");
      if (!acc[key]) acc[key] = [];
      acc[key].push(issue.message);
      return acc;
    }, {});

    res.status(400).json({
      success: false,
      error: {
        code: "VALIDATION_ERROR",
        message: "Request validation failed",
        fields,
      },
    });
    return;
  }

  // Prisma errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === "P2002") {
      const conflict = new ConflictError(
        "A record with that value already exists",
      );
      res.status(conflict.statusCode).json({
        success: false,
        error: { code: conflict.code, message: conflict.message },
      });
      return;
    }
    if (err.code === "P2025") {
      const notFound = new NotFoundError("Record");
      res.status(notFound.statusCode).json({
        success: false,
        error: { code: notFound.code, message: notFound.message },
      });
      return;
    }
  }

  // Known operational errors
  if (err instanceof AppError) {
    const body: Record<string, unknown> = {
      success: false,
      error: { code: err.code, message: err.message },
    };
    if (err instanceof ValidationError && err.fields) {
      (body["error"] as Record<string, unknown>)["fields"] = err.fields;
    }
    res.status(err.statusCode).json(body);
    return;
  }

  // Unknown errors — never leak details in production
  logger.error("Unhandled error:", err);

  res.status(500).json({
    success: false,
    error: {
      code: "INTERNAL_ERROR",
      message:
        env.NODE_ENV === "production"
          ? "An unexpected error occurred"
          : err instanceof Error
            ? err.message
            : "An unexpected error occurred",
    },
  });
}

export default errorHandler;
