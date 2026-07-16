import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';
import 'package:brewphoria/features/shop/domain/modifier_model.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@freezed
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String id,
    required int quantity,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: numToDouble) @Default(0.0) double unitPrice,
    @Default(<SelectedModifierModel>[]) List<SelectedModifierModel> modifiers,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
    required ProductModel product,
  }) = _CartItemModel;

  const CartItemModel._();

  /// Effective per-unit price (base + modifier deltas); falls back to the
  /// product price for legacy items with no stored unitPrice.
  double get effectiveUnitPrice =>
      unitPrice > 0 ? unitPrice : product.price;

  /// "Large · Oat · +Caramel" style summary for the cart line.
  String get modifierLabel => modifiers.map((m) => m.label).join(' · ');

  factory CartItemModel.fromJson(Map<String, dynamic> json) => _$CartItemModelFromJson(json);
}

ProductModel _productFromJson(Map<String, dynamic> json) =>
    ProductModel.fromJson(json);

Map<String, dynamic> _productToJson(ProductModel model) => model.toJson();
