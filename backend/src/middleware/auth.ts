import { Request, Response, NextFunction } from "express";
import { firebaseAuth } from "../config/firebase";
import { prisma } from "../config/database";
import { UnauthorizedError } from "../utils/errors";
import { Role } from "@prisma/client";

export interface AuthenticatedUser {
  id: string;
  firebaseUid: string;
  email: string;
  displayName: string;
  role: Role;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}

export async function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      throw new UnauthorizedError("Missing or invalid authorization header");
    }

    const idToken = authHeader.split(" ")[1];
    if (!idToken) {
      throw new UnauthorizedError("Missing token");
    }

    let decodedToken: import("firebase-admin/auth").DecodedIdToken;
    try {
      decodedToken = await firebaseAuth.verifyIdToken(idToken);
    } catch {
      throw new UnauthorizedError("Invalid or expired token");
    }

    const user = await prisma.user.findUnique({
      where: { firebaseUid: decodedToken.uid },
      select: {
        id: true,
        firebaseUid: true,
        email: true,
        displayName: true,
        role: true,
      },
    });

    if (!user) {
      throw new UnauthorizedError("User not found. Please login first.");
    }

    req.user = user;
    next();
  } catch (error) {
    next(error);
  }
}
