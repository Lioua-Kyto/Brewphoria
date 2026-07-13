import { User } from "@prisma/client";
import { firebaseAuth } from "../config/firebase";
import { UserRepository } from "../repositories/UserRepository";
import { LoyaltyRepository } from "../repositories/LoyaltyRepository";
import { UnauthorizedError } from "../utils/errors";

const userRepo = new UserRepository();
const loyaltyRepo = new LoyaltyRepository();

const cap = (s: string) => (s ? s[0]!.toUpperCase() + s.slice(1) : s);

/**
 * Best-effort first/last name. Uses the provider display name when it's a real
 * name; otherwise derives a friendly first name from the email local-part so
 * greetings never show a raw email address.
 */
function deriveNames(
  name: string | undefined,
  email: string,
): { firstName: string | null; lastName: string | null } {
  if (name && name.trim() && !name.includes("@")) {
    const parts = name.trim().split(/\s+/);
    return {
      firstName: cap(parts[0]!),
      lastName: parts.length > 1 ? parts.slice(1).map(cap).join(" ") : null,
    };
  }
  const local = (email.split("@")[0] ?? "").replace(/[._\-+0-9]+/g, " ").trim();
  const parts = local.split(/\s+/).filter(Boolean);
  if (parts.length === 0) return { firstName: null, lastName: null };
  return {
    firstName: cap(parts[0]!),
    lastName: parts.length > 1 ? parts.slice(1).map(cap).join(" ") : null,
  };
}

export class AuthService {
  async login(idToken: string): Promise<{
    user: User;
    loyaltySummary: {
      currentPoints: number;
      tier: string;
      lifetimePoints: number;
    };
  }> {
    let decoded: import("firebase-admin/auth").DecodedIdToken;
    try {
      decoded = await firebaseAuth.verifyIdToken(idToken);
    } catch {
      throw new UnauthorizedError("Invalid or expired Firebase ID token");
    }

    const email = decoded.email ?? "";
    const { firstName, lastName } = deriveNames(decoded.name, email);

    const user = await userRepo.upsertByFirebaseUid({
      firebaseUid: decoded.uid,
      email,
      displayName: decoded.name ?? decoded.email ?? "User",
      firstName,
      lastName,
      avatarUrl: decoded.picture,
    });

    const loyalty = await loyaltyRepo.findAccountByUserId(user.id);
    const loyaltySummary = {
      currentPoints: loyalty?.currentPoints ?? 0,
      tier: loyalty?.tier ?? "BRONZE",
      lifetimePoints: loyalty?.lifetimePoints ?? 0,
    };

    return { user, loyaltySummary };
  }

  async logout(userId: string): Promise<void> {
    await userRepo.updateFcmToken(userId, null);
  }

  async updateFcmToken(userId: string, fcmToken: string): Promise<void> {
    await userRepo.updateFcmToken(userId, fcmToken);
  }
}
