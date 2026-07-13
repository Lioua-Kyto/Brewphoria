import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/router/route_names.dart';
import 'package:coffee_card/core/errors/app_exception.dart';
import 'package:coffee_card/core/widgets/app_error_widget.dart';
import 'package:coffee_card/core/widgets/app_network_image.dart';
import 'package:coffee_card/core/widgets/badges.dart';
import 'package:coffee_card/core/utils/extensions.dart';
import 'package:coffee_card/features/orders/presentation/providers/orders_provider.dart';
import 'package:coffee_card/features/checkout/domain/order_model.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: AppTextStyles.headlineMedium),
      ),
      body: orderAsync.when(
        data: (order) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status & summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id.substring(0, 8).toUpperCase()}',
                                style: AppTextStyles.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.createdAt.toDisplayDateTime,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        OrderStatusBadge(status: order.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items
            Text('Items', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            ...order.items.map((item) => _OrderItemTile(
                item: item, orderId: orderId, orderStatus: order.status)),
            const SizedBox(height: 16),

            // Delivery address
            if (order.address != null) ...[
              Text('Delivery Address', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.address!.fullName,
                                style: AppTextStyles.labelLarge),
                            Text(order.address!.phone,
                                style: AppTextStyles.bodySmall),
                            Text(
                              '${order.address!.street}, ${order.address!.city}, ${order.address!.state}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Price breakdown
            Text('Payment Summary', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Row('Subtotal', order.subtotal.toCurrency),
                    _Row('Delivery fee', order.deliveryFee.toCurrency),
                    if (order.discount > 0)
                      _Row('Discount',
                          '-${order.discount.toCurrency}',
                          color: AppColors.statusDelivered),
                    if (order.loyaltyDiscount > 0)
                      _Row('Loyalty discount',
                          '-${order.loyaltyDiscount.toCurrency}',
                          color: AppColors.tierGold),
                    const Divider(height: 16),
                    _Row('Total', order.total.toCurrency,
                        bold: true,
                        color: Theme.of(context).colorScheme.primary),
                    if (order.pointsEarned > 0) ...[
                      const SizedBox(height: 8),
                      _Row(
                        'Points earned',
                        '+${order.pointsEarned.toPoints} pts',
                        color: AppColors.tierGold,
                      ),
                    ],
                    if (order.pointsRedeemed > 0)
                      _Row(
                        'Points redeemed',
                        '-${order.pointsRedeemed.toPoints} pts',
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment method
            Card(
              child: ListTile(
                leading: Icon(
                  order.paymentMethod == 'COD'
                      ? Icons.payments_outlined
                      : Icons.account_balance_outlined,
                  color: AppColors.textSecondary,
                ),
                title: const Text('Payment Method'),
                trailing: Text(
                  order.paymentMethod == 'COD'
                      ? 'Cash on Delivery'
                      : 'Bank Transfer',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: friendlyError(e),
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.item,
    required this.orderId,
    required this.orderStatus,
  });

  final OrderItemModel item;
  final String orderId;
  final String orderStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(
                url: item.productImage,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity} × ${item.unitPrice.toCurrency}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.subtotal.toCurrency,
                    style: AppTextStyles.labelLarge),
                if (orderStatus == 'DELIVERED' && !(item.hasReview ?? false)) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => context.pushNamed(
                      RouteNames.writeReview,
                      pathParameters: {'orderId': item.id},
                    ),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 28)),
                    child: const Text('Review', style: TextStyle(fontSize: 12)),
                  ),
                ],
                if (item.hasReview == true)
                  const Icon(Icons.check_circle,
                      size: 16, color: AppColors.statusDelivered),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false, this.color});

  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.labelLarge.copyWith(fontSize: 16)
        : AppTextStyles.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style.copyWith(color: color)),
        ],
      ),
    );
  }
}
