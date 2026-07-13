/**
 * link-firebase-users.ts
 *
 * Creates real Firebase Auth accounts for every seed user, then updates the
 * matching Postgres row's `firebaseUid` so they can log in through the app.
 *
 * Run once after seeding:
 *   npm run link-firebase-users
 *
 * Default password for all test accounts: BrewPhoria123!
 */

import { config } from 'dotenv';
import admin from 'firebase-admin';
import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';

config();

// ─── Firebase Admin init ────────────────────────────────────────────────────
const privateKey = (process.env.FIREBASE_PRIVATE_KEY ?? '').replace(/\\n/g, '\n');
const firebaseApp =
  admin.apps.length > 0
    ? (admin.apps[0] as admin.app.App)
    : admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID!,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL!,
          privateKey,
        }),
      });
const auth = firebaseApp.auth();

// ─── Prisma init ─────────────────────────────────────────────────────────────
const connectionString = process.env.DATABASE_URL;
if (!connectionString) throw new Error('DATABASE_URL is not set');
const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

// ─── Seed accounts ───────────────────────────────────────────────────────────
const DEFAULT_PASSWORD = 'BrewPhoria123!';

const SEED_ACCOUNTS = [
  { email: 'admin@brewphoria.com',  displayName: 'BrewPhoria Admin',  note: 'ADMIN  — promote role after' },
  { email: 'alice@example.com',     displayName: 'Alice Johnson',      note: 'GOLD loyalty'   },
  { email: 'bob@example.com',       displayName: 'Bob Martinez',       note: 'SILVER loyalty' },
  { email: 'carol@example.com',     displayName: 'Carol Williams',     note: 'BRONZE loyalty' },
  { email: 'david@example.com',     displayName: 'David Kim',          note: 'GOLD loyalty'   },
  { email: 'emma@example.com',      displayName: 'Emma Thompson',      note: 'BRONZE loyalty' },
];

// ─── Main ─────────────────────────────────────────────────────────────────────
async function main() {
  console.log('🔗  Linking seed users to Firebase Auth…\n');

  for (const account of SEED_ACCOUNTS) {
    let firebaseUid: string;

    // 1. Get or create the Firebase Auth user
    try {
      const existing = await auth.getUserByEmail(account.email);
      firebaseUid = existing.uid;
      console.log(`   ⏭  ${account.email} — already exists in Firebase (uid: ${firebaseUid})`);
    } catch {
      // User doesn't exist yet — create them
      const created = await auth.createUser({
        email: account.email,
        password: DEFAULT_PASSWORD,
        displayName: account.displayName,
        emailVerified: true,
      });
      firebaseUid = created.uid;
      console.log(`   ✅  ${account.email} — created (uid: ${firebaseUid})`);
    }

    // 2. Update the Postgres row to use the real Firebase UID
    const updated = await prisma.user.updateMany({
      where: { email: account.email },
      data: { firebaseUid },
    });

    if (updated.count === 0) {
      console.log(`   ⚠️  ${account.email} — not found in Postgres (run npm run seed first)`);
    } else {
      console.log(`   📝  ${account.email} — Postgres firebaseUid updated  [${account.note}]`);
    }

    console.log();
  }

  console.log('─'.repeat(60));
  console.log('✅  Done!\n');
  console.log('Login credentials for all test accounts:');
  console.log(`   Password: ${DEFAULT_PASSWORD}\n`);
  console.log('Accounts:');
  for (const a of SEED_ACCOUNTS) {
    console.log(`   ${a.email.padEnd(30)} ${a.note}`);
  }
  console.log();
  console.log('⚠️  To enable the admin panel, promote admin@brewphoria.com:');
  console.log('   npm run prisma:studio  →  User table  →  set role = ADMIN');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
