import { Request, Response, NextFunction } from "express";
import { Role } from "@prisma/client";
import { ForbiddenError, UnauthorizedError } from "../utils/errors";

export function requireRole(...roles: Role[]) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      next(new UnauthorizedError());
      return;
    }
    if (!roles.includes(req.user.role)) {
      next(
        new ForbiddenError(
          "You do not have permission to access this resource",
        ),
      );
      return;
    }
    next();
  };
}

export function requireAdmin(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  requireRole(Role.ADMIN)(req, res, next);
}
