export class AppError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly isOperational: boolean;

  constructor(statusCode: number, code: string, message: string) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;
    Object.setPrototypeOf(this, new.target.prototype);
    Error.captureStackTrace(this, this.constructor);
  }
}

export class NotFoundError extends AppError {
  constructor(resource = "Resource") {
    super(
      404,
      `${resource.toUpperCase().replace(/\s+/g, "_")}_NOT_FOUND`,
      `${resource} not found`,
    );
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = "Authentication required") {
    super(401, "UNAUTHORIZED", message);
  }
}

export class ForbiddenError extends AppError {
  constructor(message = "Insufficient permissions") {
    super(403, "FORBIDDEN", message);
  }
}

export class ValidationError extends AppError {
  public readonly fields?: Record<string, string[]>;

  constructor(message: string, fields?: Record<string, string[]>) {
    super(400, "VALIDATION_ERROR", message);
    this.fields = fields;
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(409, "CONFLICT", message);
  }
}

export class BadRequestError extends AppError {
  constructor(message: string, code = "BAD_REQUEST") {
    super(400, code, message);
  }
}

export class InternalError extends AppError {
  constructor(message = "An unexpected error occurred") {
    super(500, "INTERNAL_ERROR", message);
  }
}
