import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:brewphoria/features/cart/domain/cart_item_model.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

@freezed
class CartModel with _$CartModel {
  const factory CartModel({
    required String id,
    @Default([])
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson)
    List<CartItemModel> items,
  }) = _CartModel;

  factory CartModel.fromJson(Map<String, dynamic> json) => _$CartModelFromJson(json);
}

List<CartItemModel> _itemsFromJson(List<dynamic> json) =>
    json.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();

List<Map<String, dynamic>> _itemsToJson(List<CartItemModel> items) =>
    items.map((e) => e.toJson()).toList();
