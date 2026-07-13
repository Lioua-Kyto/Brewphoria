import { PrismaClient } from "@prisma/client";
import { Pool } from "pg";

async function checkPrismaAdapter() {
  console.log("--- Prisma 7 Adapter Check ---");

  console.log("\n1. Is @prisma/adapter-pg required in Prisma 7?");
  console.log(
    "No, it is NOT strictly required. Prisma 7 still includes its built-in Rust-based query engine by default.",
  );
  console.log(
    "You only need @prisma/adapter-pg if you want to use the Node.js `pg` driver (e.g., for Edge environments like Cloudflare Workers/Vercel Edge, or to use `pg` specific connection pooling).",
  );

  console.log("\n2. How to instantiate it (if you choose to use it):");

  try {
    // We dynamically import to avoid crashing if you haven't installed it yet
    const { PrismaPg } = await import("@prisma/adapter-pg");

    console.log("✅ @prisma/adapter-pg is installed. Instantiating...");

    // Step 1: Initialize a standard pg Pool
    const connectionString =
      process.env.DATABASE_URL ||
      "postgresql://postgres:postgres@localhost:5432/mydb";
    const pool = new Pool({ connectionString });

    // Step 2: Pass the pool to the PrismaPg adapter
    const adapter = new PrismaPg(pool);

    // Step 3: Pass the adapter to PrismaClient
    const prisma = new PrismaClient({ adapter });

    console.log(
      "✅ Successfully instantiated PrismaClient with the pg adapter!",
    );

    // Cleanup
    await prisma.$disconnect();
    await pool.end();
  } catch (error: any) {
    if (
      error.code === "ERR_MODULE_NOT_FOUND" ||
      error.message.includes("Cannot find module")
    ) {
      console.log("❌ @prisma/adapter-pg is NOT installed in this project.");
      console.log("To use it, you would need to run:");
      console.log("  npm install @prisma/adapter-pg pg");
      console.log("  npm install -D @types/pg");

      console.log("\nCode example for instantiation:");
      console.log(`
  import { Pool } from 'pg';
  import { PrismaPg } from '@prisma/adapter-pg';
  import { PrismaClient } from '@prisma/client';

  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const adapter = new PrismaPg(pool);
  const prisma = new PrismaClient({ adapter });
      `);
    } else {
      console.error("An error occurred during instantiation:", error.message);
    }
  }
}

checkPrismaAdapter().catch(console.error);
