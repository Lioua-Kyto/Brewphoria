// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemModelImpl _$$CartItemModelImplFromJson(Map<String, dynamic> json) =>
    _$CartItemModelImpl(
      id: json['id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice:
          json['unitPrice'] == null ? 0.0 : numToDouble(json['unitPrice']),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) =>
                  SelectedModifierModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SelectedModifierModel>[],
      product: _productFromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CartItemModelImplToJson(_$CartItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'modifiers': instance.modifiers,
      'product': _productToJson(instance.product),
    };
