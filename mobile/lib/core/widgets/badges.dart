import 'package:flutter/material.dart';
import 'package:coffee_card/core/constants/app_colors.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }

  Color get _color => switch (status) {
        'PENDING' => AppColors.statusPending,
        'CONFIRMED' => AppColors.statusConfirmed,
        'PREPARING' => AppColors.statusPreparing,
        'OUT_FOR_DELIVERY' => AppColors.statusOutForDelivery,
        'DELIVERED' => AppColors.statusDelivered,
        'CANCELLED' => AppColors.statusCancelled,
        'REFUNDED' => AppColors.statusRefunded,
        _ => AppColors.textSecondary,
      };

  String get _label => switch (status) {
        'OUT_FOR_DELIVERY' => 'Out for Delivery',
        _ => status.split('_').map((w) => w[0] + w.substring(1).toLowerCase()).join(' '),
      };
}

class LoyaltyTierBadge extends StatelessWidget {
  const LoyaltyTierBadge({required this.tier, super.key});

  final String tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            tier,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color => switch (tier) {
        'BRONZE' => AppColors.tierBronze,
        'SILVER' => AppColors.tierSilver,
        'GOLD' => AppColors.tierGold,
        'PLATINUM' => AppColors.tierPlatinum,
        _ => AppColors.textSecondary,
      };
}
