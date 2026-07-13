import { Order, OrderStatus, Prisma } from "@prisma/client";
import { OrderRepository } from "../repositories/OrderRepository";
import { CartRepository } from "../repositories/CartRepository";
import { ProductRepository } from "../repositories/ProductRepository";
import { UserRepository } from "../repositories/UserRepository";
import { LoyaltyRepository } from "../repositories/LoyaltyRepository";
import { NotificationService } from "./NotificationService";
import { prisma } from "../config/database";
import {
  NotFoundError,
  BadRequestError,
  ForbiddenError,
} from "../utils/errors";
import {
  calculateLoyaltyTier,
  getLoyaltyMultiplier,
  deliveryFeeFromSubtotal,
  pointsToDiscount,
  pointsExpiryDate,
} from "../utils/utils";
import { buildPaginatedResult, PaginatedResult } from "../utils/pagination";

const orderRepo = new OrderRepository();
const cartRepo = new CartRepository();
const productRepo = new ProductRepository();
const userRepo = new UserRepository();
const loyaltyRepo = new LoyaltyRepository();
const notifService = new NotificationService();

const POINTS_PER_DOLLAR = 10;

export class OrderService {
  /**
   * Checkout — no payment gateway.
   * Validates cart, recalculates totals server-side, then confirms the order
   * in a single transaction (deduct stock, clear cart, award loyalty points).
   */
  async checkout(
    userId: string,
    addressId: string,
    pointsToRedeem = 0,
    paymentMethod = "COD",
    notes?: string,
    tip = 0,
  ): Promise<Order> {
    // 1. Fetch cart
    const cart = await cartRepo.findByUserId(userId);
    if (!cart || cart.items.length === 0) {
      throw new BadRequestError("Your cart is empty");
    }

    // 2. Validate address ownership
    const address = await userRepo.findAddressById(addressId);
    if (!address) throw new NotFoundError("Address");
    if (address.userId !== userId) throw new ForbiddenError("Not your address");

    // 3. Re-fetch all product prices from DB (NEVER trust client prices)
    const productIds = cart.items.map((i) => i.productId);
    const products = await productRepo.findByIds(productIds);
    const productMap = new Map(products.map((p) => [p.id, p]));

    // 4. Validate stock & build order items (unit price includes modifiers)
    const orderItems = cart.items.map((item) => {
      const product = productMap.get(item.productId);
      if (!product || !product.isActive) {
        throw new BadRequestError(
          `Product "${item.product.name}" is no longer available`,
        );
      }
      if (product.stock < item.quantity) {
        throw new BadRequestError(
          `Insufficient stock for "${product.name}". Available: ${product.stock}`,
        );
      }
      const modifiers = Array.isArray(item.modifiers)
        ? (item.modifiers as { priceDelta?: number }[])
        : [];
      const deltas = modifiers.reduce((s, m) => s + Number(m.priceDelta ?? 0), 0);
      const unitPrice = Number(product.price) + deltas;
      const subtotal = unitPrice * item.quantity;
      return {
        productId: item.productId,
        productName: product.name,
        productImage: product.images[0] ?? "",
        unitPrice,
        quantity: item.quantity,
        subtotal,
        modifiers: item.modifiers,
      };
    });

    const subtotal = orderItems.reduce((sum, i) => sum + i.subtotal, 0);
    const deliveryFee = deliveryFeeFromSubtotal(subtotal);

    // 5. Validate & calculate loyalty discount
    let loyaltyDiscount = 0;
    const loyaltyAccount = await loyaltyRepo.findAccountByUserId(userId);
    if (pointsToRedeem > 0) {
      if (!loyaltyAccount)
        throw new BadRequestError("No loyalty account found");
      if (pointsToRedeem > loyaltyAccount.currentPoints) {
        throw new BadRequestError(
          `Cannot redeem ${pointsToRedeem} points. You only have ${loyaltyAccount.currentPoints}.`,
        );
      }
      loyaltyDiscount = pointsToDiscount(pointsToRedeem);
    }

    const total = Math.max(0, subtotal + deliveryFee + tip - loyaltyDiscount);

    // 6. Calculate points to earn
    const tier = loyaltyAccount?.tier ?? "BRONZE";
    const multiplier = getLoyaltyMultiplier(tier);
    const pointsEarned = Math.floor(subtotal * POINTS_PER_DOLLAR * multiplier);

    // Estimated ready time: a base prep window plus a little per extra cup,
    // capped so large orders don't quote an unreasonable wait.
    const totalQty = orderItems.reduce((sum, i) => sum + i.quantity, 0);
    const prepMinutes = Math.min(30, 8 + Math.max(0, totalQty - 1) * 2);
    const estimatedReadyAt = new Date(Date.now() + prepMinutes * 60_000);

    // 7. Create order + deduct stock + clear cart + award loyalty in one transaction
    const order = await prisma.$transaction(async (tx) => {
      // Create CONFIRMED order
      const newOrder = await tx.order.create({
        data: {
          userId,
          addressId,
          subtotal,
          deliveryFee,
          discount: 0,
          loyaltyDiscount,
          tip,
          total,
          pointsEarned,
          pointsRedeemed: pointsToRedeem,
          paymentMethod,
          status: "CONFIRMED",
          notes,
          estimatedReadyAt,
          items: {
            create: orderItems.map((item) => ({
              productId: item.productId,
              productName: item.productName,
              productImage: item.productImage,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              subtotal: item.subtotal,
              modifiers: item.modifiers as Prisma.InputJsonValue,
            })),
          },
        },
        include: { items: true, address: true },
      });

      // Deduct stock
      for (const item of orderItems) {
        await tx.product.update({
          where: { id: item.productId },
          data: { stock: { decrement: item.quantity } },
        });
      }

      // Clear cart
      await tx.cartItem.deleteMany({ where: { cartId: cart.id } });

      // Award loyalty points
      const account = loyaltyAccount
        ? await tx.loyaltyAccount.findUnique({ where: { userId } })
        : null;

      if (account && pointsEarned > 0) {
        const newCurrent = Math.max(
          0,
          account.currentPoints + pointsEarned - pointsToRedeem,
        );
        const newLifetime = account.lifetimePoints + pointsEarned;
        const newTier = calculateLoyaltyTier(newLifetime);

        await tx.loyaltyAccount.update({
          where: { id: account.id },
          data: {
            currentPoints: newCurrent,
            lifetimePoints: newLifetime,
            tier: newTier,
          },
        });

        await tx.loyaltyTransaction.create({
          data: {
            accountId: account.id,
            orderId: newOrder.id,
            type: "EARNED",
            points: pointsEarned,
            description: `Points earned from order #${newOrder.id.slice(-8)}`,
            expiresAt: pointsExpiryDate(),
          },
        });

        if (pointsToRedeem > 0) {
          await tx.loyaltyTransaction.create({
            data: {
              accountId: account.id,
              orderId: newOrder.id,
              type: "REDEEMED",
              points: -pointsToRedeem,
              description: `Points redeemed on order #${newOrder.id.slice(-8)}`,
            },
          });
        }

        if (newTier !== account.tier) {
          await tx.notification.create({
            data: {
              userId,
              type: "LOYALTY_TIER_UP",
              title: "🎉 Tier Upgraded!",
              body: `Congratulations! You've reached ${newTier} tier!`,
              data: { newTier },
            },
          });
        }
      }

      return newOrder;
    });

    // 8. Push notifications (outside transaction — best-effort)
    const user = await userRepo.findById(userId);
    if (user?.fcmToken) {
      await notifService.sendToUser(
        userId,
        "ORDER_STATUS_CHANGED",
        "Order Confirmed! ☕",
        "Your BrewPhoria order has been confirmed and is being prepared.",
        { orderId: order.id, status: "CONFIRMED" },
      );
    }

    await notifService.sendToAdmins(
      "NEW_ORDER",
      "New Order Received",
      "A new order has been placed.",
      { orderId: order.id },
    );

    return order;
  }

  async getOrders(
    userId: string,
    page: number,
    limit: number,
  ): Promise<PaginatedResult<Order>> {
    const { data, total } = await orderRepo.findMany({ userId, page, limit });
    return buildPaginatedResult(data, total, page, limit);
  }

  async getOrder(userId: string, orderId: string): Promise<Order> {
    const order = await orderRepo.findById(orderId);
    if (!order) throw new NotFoundError("Order");
    if (order.userId !== userId) throw new ForbiddenError("Not your order");
    return order;
  }

  async adminGetOrders(filters: {
    status?: OrderStatus;
    dateFrom?: Date;
    dateTo?: Date;
    page: number;
    limit: number;
  }): Promise<PaginatedResult<Order>> {
    const { data, total } = await orderRepo.findMany(filters);
    return buildPaginatedResult(data, total, filters.page, filters.limit);
  }

  async adminUpdateStatus(
    orderId: string,
    status: OrderStatus,
  ): Promise<Order> {
    const order = await orderRepo.findById(orderId);
    if (!order) throw new NotFoundError("Order");

    const updated = await orderRepo.updateStatus(orderId, status);

    await notifService.sendToUser(
      order.userId,
      "ORDER_STATUS_CHANGED",
      "Order Update",
      `Your order status has changed to: ${status.replace(/_/g, " ")}`,
      // `type` in the data payload drives the mobile deep-link on tap.
      { type: "ORDER_STATUS_CHANGED", orderId, status },
    );

    // Post-delivery review nudge — deep-links into the write-review screen.
    if (status === "DELIVERED") {
      await notifService.sendToUser(
        order.userId,
        "ORDER_STATUS_CHANGED",
        "How was your order? ☕",
        "Tap to rate what you ordered and help others choose.",
        { type: "REVIEW_REQUEST", orderId },
      );
    }

    return updated;
  }
}
