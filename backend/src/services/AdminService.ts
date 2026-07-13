import { OrderRepository } from "../repositories/OrderRepository";
import { redis } from "../config/redis";

const orderRepo = new OrderRepository();
const DASHBOARD_CACHE_KEY = "brewphoria:dashboard:stats";
const DASHBOARD_TTL = 60; // 1 min

export interface DashboardStats {
  todayRevenue: number;
  totalOrders: number;
  activeUsers: number;
  topProducts: { productName: string; totalQuantity: number }[];
  recentOrders: unknown[];
}

export class AdminService {
  async getDashboardStats(): Promise<DashboardStats> {
    const cached = await redis.get<DashboardStats>(DASHBOARD_CACHE_KEY);
    if (cached) return cached;

    const stats = await orderRepo.getDashboardStats();
    await redis.set(DASHBOARD_CACHE_KEY, stats, DASHBOARD_TTL);
    return stats;
  }
}
