import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/router/route_names.dart';
import 'package:coffee_card/core/utils/extensions.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({this.orderData, super.key});

  final Map<String, dynamic>? orderData;

  @override
  Widget build(BuildContext context) {
    final total = (orderData?['total'] as num?)?.toDouble() ?? 0.0;
    final pointsEarned = (orderData?['pointsEarned'] as num?)?.toInt() ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.statusDelivered.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 72,
                  color: AppColors.statusDelivered,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Order Placed!',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your order has been confirmed. We\'ll start preparing your coffee right away.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (total > 0)
                _InfoTile(
                  icon: Icons.receipt_outlined,
                  label: 'Order Total',
                  value: total.toCurrency,
                ),
              if (pointsEarned > 0) ...[
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.star,
                  label: 'Points Earned',
                  value: '+${pointsEarned.toPoints} pts',
                  valueColor: AppColors.tierGold,
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.goNamed(RouteNames.orders),
                child: const Text('View My Orders'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.goNamed(RouteNames.shop),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
