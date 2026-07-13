-- CreateEnum
CREATE TYPE "ProductType" AS ENUM ('DRINK', 'BEANS', 'MERCH');

-- AlterTable
-- New rows default to MERCH (the most restrictive: no customization); the
-- backfill below assigns correct types to existing catalogue rows so the
-- product-type gating in ProductService applies without a re-seed.
ALTER TABLE "Product" ADD COLUMN     "type" "ProductType" NOT NULL DEFAULT 'MERCH';

-- Backfill: drink categories → DRINK.
UPDATE "Product" p SET "type" = 'DRINK'
FROM "Category" c
WHERE p."categoryId" = c."id"
  AND c."name" IN ('Espresso & Hot Drinks', 'Cold Brew & Iced');

-- Backfill: whole/ground coffee → BEANS.
UPDATE "Product" p SET "type" = 'BEANS'
FROM "Category" c
WHERE p."categoryId" = c."id"
  AND c."name" = 'Coffee Beans & Grounds';

-- Backfill: the drinkable items inside the mixed "Tea & Alternatives" category
-- (the rest of that category — loose tea, milk alternatives — stays MERCH).
UPDATE "Product" SET "type" = 'DRINK'
WHERE "name" IN ('Ceremonial Matcha 30g', 'Culinary Matcha 100g', 'Chai Concentrate 500ml');

-- Everything else (Pastries, Merchandise, remaining Tea & Alternatives) keeps
-- the MERCH default.
