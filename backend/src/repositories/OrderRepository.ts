import { Prisma, Order, OrderItem, OrderStatus } from "@prisma/client";
import { prisma } from "../config/database";

export interface CreateOrderData {
  userId: string;
  addressId: string;
  items: {
    productId: string;
    productName: string;
    productImage: string;
    unitPrice: number;
    quantity: number;
    subtotal: number;
  }[];
  subtotal: number;
  deliveryFee: number;
  discount: number;
  loyaltyDiscount: number;
  total: number;
  pointsEarned: number;
  pointsRedeemed: number;
  paymentMethod: string;
  notes?: string;
}

export interface OrderFilters {
  userId?: string;
  status?: OrderStatus;
  dateFrom?: Date;
  dateTo?: Date;
  page: number;
  limit: number;
}

export class OrderRepository {
  async create(data: CreateOrderData): Promise<Order> {
    return prisma.order.create({
      data: {
        userId: data.userId,
        addressId: data.addressId,
        subtotal: data.subtotal,
        deliveryFee: data.deliveryFee,
        discount: data.discount,
        loyaltyDiscount: data.loyaltyDiscount,
        total: data.total,
        pointsEarned: data.pointsEarned,
        pointsRedeemed: data.pointsRedeemed,
        paymentMethod: data.paymentMethod,
        notes: data.notes,
        items: {
          create: data.items.map((item) => ({
            productId: item.productId,
            productName: item.productName,
            productImage: item.productImage,
            unitPrice: item.unitPrice,
            quantity: item.quantity,
            subtotal: item.subtotal,
          })),
        },
      },
      include: { items: true },
    });
  }

  async findById(id: string): Promise<(Order & { items: OrderItem[] }) | null> {
    return prisma.order.findUnique({
      where: { id },
      include: {
        items: {
          include: {
            product: { select: { id: true, slug: true } },
            review: { select: { id: true } },
          },
        },
        address: true,
        user: { select: { id: true, displayName: true, email: true } },
      },
    });
  }

  async findMany(
    filters: OrderFilters,
  ): Promise<{ data: Order[]; total: number }> {
    const where: Prisma.OrderWhereInput = {};
    if (filters.userId) where.userId = filters.userId;
    if (filters.status) where.status = filters.status;
    if (filters.dateFrom || filters.dateTo) {
      where.createdAt = {
        ...(filters.dateFrom !== undefined ? { gte: filters.dateFrom } : {}),
        ...(filters.dateTo !== undefined ? { lte: filters.dateTo } : {}),
      };
    }

    const skip = (filters.page - 1) * filters.limit;
    const [data, total] = await prisma.$transaction([
      prisma.order.findMany({
        where,
        skip,
        take: filters.limit,
        include: { items: true, address: true },
        orderBy: { createdAt: "desc" },
      }),
      prisma.order.count({ where }),
    ]);

    return { data, total };
  }

  async updateStatus(id: string, status: OrderStatus): Promise<Order> {
    return prisma.order.update({ where: { id }, data: { status } });
  }

  async getDashboardStats(): Promise<{
    todayRevenue: number;
    totalOrders: number;
    activeUsers: number;
    topProducts: { productName: string; totalQuantity: number }[];
    recentOrders: Order[];
  }> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      todayRevenue,
      totalOrders,
      activeUsers,
      topProductsRaw,
      recentOrders,
    ] = await prisma.$transaction([
      prisma.order.aggregate({
        where: {
          createdAt: { gte: today },
          status: { notIn: ["CANCELLED", "REFUNDED"] },
        },
        _sum: { total: true },
      }),
      prisma.order.count(),
      prisma.user.count(),
      prisma.orderItem.groupBy({
        by: ["productName"],
        _sum: { quantity: true },
        orderBy: { _sum: { quantity: "desc" } },
        take: 5,
      }),
      prisma.order.findMany({
        take: 10,
        orderBy: { createdAt: "desc" },
        include: { user: { select: { displayName: true, email: true } } },
      }),
    ]);

    return {
      todayRevenue: Number(todayRevenue._sum?.total ?? 0),
      totalOrders,
      activeUsers,
      topProducts: topProductsRaw.map((p) => ({
        productName: p.productName,
        totalQuantity: p._sum?.quantity ?? 0,
      })),
      recentOrders,
    };
  }
}
