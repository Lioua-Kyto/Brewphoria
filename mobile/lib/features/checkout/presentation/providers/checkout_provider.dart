import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_card/features/checkout/data/order_repository.dart';
import 'package:coffee_card/features/orders/domain/order_history_model.dart';
import 'package:coffee_card/features/loyalty/data/loyalty_remote_datasource.dart';
import 'package:coffee_card/features/loyalty/domain/loyalty_model.dart';
import 'package:coffee_card/features/cart/presentation/providers/cart_provider.dart';

part 'checkout_provider.g.dart';

@riverpod
OrderRepository orderRepository(Ref ref) => OrderRepository();

@riverpod
class RedemptionNotifier extends _$RedemptionNotifier {
  @override
  AsyncValue<RedemptionValidation?> build() => const AsyncValue.data(null);

  Future<void> validate(int points) async {
    if (points <= 0) {
      state = const AsyncValue.data(null);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => LoyaltyRemoteDatasource().validateRedemption(points),
    );
  }

  void clear() => state = const AsyncValue.data(null);
}

@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  AsyncValue<OrderModel?> build() => const AsyncValue.data(null);

  Future<OrderModel?> placeOrder(CheckoutRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(orderRepositoryProvider).checkout(request),
    );
    state = result;
    if (result.hasValue && result.value != null) {
      await ref.read(cartNotifierProvider.notifier).clearCart();
    }
    return result.valueOrNull;
  }
}
