import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coffee_card/features/checkout/domain/order_model.dart';

export 'package:coffee_card/features/checkout/domain/order_model.dart';

part 'order_history_model.freezed.dart';
part 'order_history_model.g.dart';

typedef OrderHistoryModel = OrderModel;

@freezed
class CheckoutRequest with _$CheckoutRequest {
  const factory CheckoutRequest({
    required String addressId,
    @Default(0) int pointsToRedeem,
    @Default('COD') String paymentMethod,
    String? notes,
    @Default(0.0) double tip,
  }) = _CheckoutRequest;

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) => _$CheckoutRequestFromJson(json);
}
