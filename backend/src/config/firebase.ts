import admin from "firebase-admin";
import type { Messaging } from "firebase-admin/messaging";
import { env } from "./env";
import { logger } from "./logger";

function initFirebase(): admin.app.App {
  if (admin.apps.length > 0) {
    return admin.apps[0] as admin.app.App;
  }

  const privateKey = env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n");

  return admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey,
    }),
  });
}

export const firebaseApp = initFirebase();
export const firebaseAuth = admin.auth();
export const firebaseMessaging: Messaging = admin.messaging();

logger.info("✅ Firebase Admin SDK initialized");
