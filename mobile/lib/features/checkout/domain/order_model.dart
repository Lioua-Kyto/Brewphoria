import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coffee_card/features/shop/domain/modifier_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String status,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double loyaltyDiscount,
    required double total,
    required int pointsEarned,
    required int pointsRedeemed,
    required String paymentMethod,
    @Default([]) List<OrderItemModel> items,
    OrderAddressModel? address,
    String? notes,
    DateTime? estimatedReadyAt,
    required DateTime createdAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
}

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    required String productId,
    required String productName,
    required String productImage,
    required double unitPrice,
    required int quantity,
    required double subtotal,
    @Default(<SelectedModifierModel>[]) List<SelectedModifierModel> modifiers,
    bool? hasReview,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);
}

@freezed
class OrderAddressModel with _$OrderAddressModel {
  const factory OrderAddressModel({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    String? label,
  }) = _OrderAddressModel;

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) => _$OrderAddressModelFromJson(json);
}
