// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      loyaltyDiscount: (json['loyaltyDiscount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      pointsEarned: (json['pointsEarned'] as num).toInt(),
      pointsRedeemed: (json['pointsRedeemed'] as num).toInt(),
      paymentMethod: json['paymentMethod'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      address: json['address'] == null
          ? null
          : OrderAddressModel.fromJson(json['address'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      estimatedReadyAt: json['estimatedReadyAt'] == null
          ? null
          : DateTime.parse(json['estimatedReadyAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'discount': instance.discount,
      'loyaltyDiscount': instance.loyaltyDiscount,
      'total': instance.total,
      'pointsEarned': instance.pointsEarned,
      'pointsRedeemed': instance.pointsRedeemed,
      'paymentMethod': instance.paymentMethod,
      'items': instance.items,
      'address': instance.address,
      'notes': instance.notes,
      'estimatedReadyAt': instance.estimatedReadyAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$OrderItemModelImpl _$$OrderItemModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemModelImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      subtotal: (json['subtotal'] as num).toDouble(),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) =>
                  SelectedModifierModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SelectedModifierModel>[],
      hasReview: json['hasReview'] as bool?,
    );

Map<String, dynamic> _$$OrderItemModelImplToJson(
        _$OrderItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'subtotal': instance.subtotal,
      'modifiers': instance.modifiers,
      'hasReview': instance.hasReview,
    };

_$OrderAddressModelImpl _$$OrderAddressModelImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderAddressModelImpl(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$$OrderAddressModelImplToJson(
        _$OrderAddressModelImpl instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'phone': instance.phone,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'label': instance.label,
    };
