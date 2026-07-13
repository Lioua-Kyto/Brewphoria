import { z } from "zod";
import dotenv from "dotenv";

dotenv.config();

const envSchema = z.object({
  NODE_ENV: z
    .enum(["development", "production", "test"])
    .default("development"),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().min(1, "DATABASE_URL is required"),
  DATABASE_URL_TEST: z.string().optional(),
  REDIS_URL: z.string().min(1, "REDIS_URL is required"),
  FIREBASE_PROJECT_ID: z.string().min(1, "FIREBASE_PROJECT_ID is required"),
  FIREBASE_CLIENT_EMAIL: z
    .string()
    .email("FIREBASE_CLIENT_EMAIL must be valid email"),
  FIREBASE_PRIVATE_KEY: z.string().min(1, "FIREBASE_PRIVATE_KEY is required"),
  GEMINI_API_KEY: z.string().min(1, "GEMINI_API_KEY is required"),
  // Server-side Google Maps Platform key (Places API New + Geocoding). Optional:
  // when unset, the /places endpoints return 503 rather than blocking boot.
  GOOGLE_MAPS_API_KEY: z.string().optional(),
  UPLOAD_DIR: z.string().default("uploads"),
  BASE_URL: z.string().default("http://localhost:3000"),
  // FCM_SERVER_KEY is not needed — firebase-admin uses the service account
  // credentials (FIREBASE_*) to call the FCM v1 API automatically.
  ALLOWED_ORIGINS: z.string().default("http://localhost:3000"),
});

const _parsed = envSchema.safeParse(process.env);

if (!_parsed.success) {
  const missing = _parsed.error.errors
    .map((e) => `  ${e.path.join(".")}: ${e.message}`)
    .join("\n");
  console.error(
    "❌ Environment validation failed. Missing or invalid variables:\n" +
      missing,
  );
  process.exit(1);
}

export const env = _parsed.data;
export type Env = typeof env;
