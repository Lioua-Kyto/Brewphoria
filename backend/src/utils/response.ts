import { Response } from "express";
import { AppError } from "./errors";
import { ValidationError } from "./errors";

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface SuccessResponse<T> {
  success: true;
  data: T;
  message: string;
  meta?: PaginationMeta;
}

export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    fields?: Record<string, string[]>;
  };
}

export function sendSuccess<T>(
  res: Response,
  data: T,
  message = "Success",
  statusCode = 200,
  meta?: PaginationMeta,
): Response {
  const body: SuccessResponse<T> = {
    success: true,
    data,
    message,
    ...(meta !== undefined ? { meta } : {}),
  };
  return res.status(statusCode).json(body);
}

export function sendError(
  res: Response,
  error: AppError | Error,
  statusCode = 500,
): Response {
  if (error instanceof AppError) {
    const responseError: ErrorResponse["error"] = {
      code: error.code,
      message: error.message,
    };

    if (error instanceof ValidationError && error.fields) {
      responseError.fields = error.fields;
    }

    const body: ErrorResponse = {
      success: false,
      error: responseError,
    };
    return res.status(error.statusCode).json(body);
  }

  const body: ErrorResponse = {
    success: false,
    error: {
      code: "INTERNAL_ERROR",
      message: "An unexpected error occurred",
    },
  };
  return res.status(statusCode).json(body);
}
