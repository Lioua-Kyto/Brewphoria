import crypto from "crypto";

export function getErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  if (typeof error === "string") return error;
  return "An unknown error occurred";
}

export function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/[\s_-]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export function hashQueryParams(params: Record<string, unknown>): string {
  const sorted = Object.keys(params)
    .sort()
    .reduce<Record<string, unknown>>((acc, key) => {
      acc[key] = params[key];
      return acc;
    }, {});
  return crypto
    .createHash("md5")
    .update(JSON.stringify(sorted))
    .digest("hex")
    .slice(0, 12);
}

export function calculateLoyaltyTier(
  lifetimePoints: number,
): "BRONZE" | "SILVER" | "GOLD" | "PLATINUM" {
  if (lifetimePoints >= 3000) return "PLATINUM";
  if (lifetimePoints >= 1500) return "GOLD";
  if (lifetimePoints >= 500) return "SILVER";
  return "BRONZE";
}

export function getLoyaltyMultiplier(
  tier: "BRONZE" | "SILVER" | "GOLD" | "PLATINUM",
): number {
  const multipliers: Record<string, number> = {
    BRONZE: 1,
    SILVER: 1.25,
    GOLD: 1.5,
    PLATINUM: 2,
  };
  return multipliers[tier] ?? 1;
}

export function calculatePointsEarned(
  subtotalCents: number,
  tier: "BRONZE" | "SILVER" | "GOLD" | "PLATINUM",
): number {
  // 10 points per $1 (subtotal in dollars), multiplied by tier multiplier
  const multiplier = getLoyaltyMultiplier(tier);
  return Math.floor((subtotalCents / 100) * 10 * multiplier);
}

export function pointsToDiscount(points: number): number {
  // 100 points = $1 discount
  return points / 100;
}

export function deliveryFeeFromSubtotal(subtotal: number): number {
  // Free delivery over $50, else $5.99
  return subtotal >= 50 ? 0 : 5.99;
}

export function pointsExpiryDate(): Date {
  const expiry = new Date();
  expiry.setFullYear(expiry.getFullYear() + 1);
  return expiry;
}
