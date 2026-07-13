/*
  Warnings:

  - Added the required column `unitPrice` to the `CartItem` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "ModifierSelectionType" AS ENUM ('SINGLE', 'MULTI');

-- DropIndex
DROP INDEX "CartItem_cartId_productId_key";

-- AlterTable
ALTER TABLE "CartItem" ADD COLUMN     "modifiers" JSONB NOT NULL DEFAULT '[]',
ADD COLUMN     "unitPrice" DECIMAL(10,2) NOT NULL;

-- AlterTable
ALTER TABLE "Order" ADD COLUMN     "tip" DECIMAL(10,2) NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "OrderItem" ADD COLUMN     "modifiers" JSONB NOT NULL DEFAULT '[]';

-- AlterTable
ALTER TABLE "Product" ADD COLUMN     "caffeineMg" INTEGER,
ADD COLUMN     "calories" INTEGER,
ADD COLUMN     "prepMinutes" INTEGER,
ADD COLUMN     "roastLevel" TEXT,
ADD COLUMN     "tastingNotes" TEXT[];

-- CreateTable
CREATE TABLE "ModifierGroup" (
    "id" TEXT NOT NULL,
    "categoryId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "selectionType" "ModifierSelectionType" NOT NULL DEFAULT 'SINGLE',
    "isRequired" BOOLEAN NOT NULL DEFAULT false,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ModifierGroup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ModifierOption" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "priceDelta" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "ModifierOption_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WishlistItem" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WishlistItem_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ModifierGroup_categoryId_idx" ON "ModifierGroup"("categoryId");

-- CreateIndex
CREATE INDEX "ModifierOption_groupId_idx" ON "ModifierOption"("groupId");

-- CreateIndex
CREATE INDEX "WishlistItem_userId_createdAt_idx" ON "WishlistItem"("userId", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "WishlistItem_userId_productId_key" ON "WishlistItem"("userId", "productId");

-- AddForeignKey
ALTER TABLE "ModifierGroup" ADD CONSTRAINT "ModifierGroup_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ModifierOption" ADD CONSTRAINT "ModifierOption_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "ModifierGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WishlistItem" ADD CONSTRAINT "WishlistItem_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WishlistItem" ADD CONSTRAINT "WishlistItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
