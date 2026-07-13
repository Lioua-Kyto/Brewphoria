// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get loyaltyDiscount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  int get pointsEarned => throw _privateConstructorUsedError;
  int get pointsRedeemed => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  List<OrderItemModel> get items => throw _privateConstructorUsedError;
  OrderAddressModel? get address => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get estimatedReadyAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) then) =
      _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call(
      {String id,
      String status,
      double subtotal,
      double deliveryFee,
      double discount,
      double loyaltyDiscount,
      double total,
      int pointsEarned,
      int pointsRedeemed,
      String paymentMethod,
      List<OrderItemModel> items,
      OrderAddressModel? address,
      String? notes,
      DateTime? estimatedReadyAt,
      DateTime createdAt});

  $OrderAddressModelCopyWith<$Res>? get address;
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discount = null,
    Object? loyaltyDiscount = null,
    Object? total = null,
    Object? pointsEarned = null,
    Object? pointsRedeemed = null,
    Object? paymentMethod = null,
    Object? items = null,
    Object? address = freezed,
    Object? notes = freezed,
    Object? estimatedReadyAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      loyaltyDiscount: null == loyaltyDiscount
          ? _value.loyaltyDiscount
          : loyaltyDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      pointsRedeemed: null == pointsRedeemed
          ? _value.pointsRedeemed
          : pointsRedeemed // ignore: cast_nullable_to_non_nullable
              as int,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItemModel>,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as OrderAddressModel?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedReadyAt: freezed == estimatedReadyAt
          ? _value.estimatedReadyAt
          : estimatedReadyAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderAddressModelCopyWith<$Res>? get address {
    if (_value.address == null) {
      return null;
    }

    return $OrderAddressModelCopyWith<$Res>(_value.address!, (value) {
      return _then(_value.copyWith(address: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
          _$OrderModelImpl value, $Res Function(_$OrderModelImpl) then) =
      __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      double subtotal,
      double deliveryFee,
      double discount,
      double loyaltyDiscount,
      double total,
      int pointsEarned,
      int pointsRedeemed,
      String paymentMethod,
      List<OrderItemModel> items,
      OrderAddressModel? address,
      String? notes,
      DateTime? estimatedReadyAt,
      DateTime createdAt});

  @override
  $OrderAddressModelCopyWith<$Res>? get address;
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
      _$OrderModelImpl _value, $Res Function(_$OrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discount = null,
    Object? loyaltyDiscount = null,
    Object? total = null,
    Object? pointsEarned = null,
    Object? pointsRedeemed = null,
    Object? paymentMethod = null,
    Object? items = null,
    Object? address = freezed,
    Object? notes = freezed,
    Object? estimatedReadyAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$OrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      loyaltyDiscount: null == loyaltyDiscount
          ? _value.loyaltyDiscount
          : loyaltyDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      pointsRedeemed: null == pointsRedeemed
          ? _value.pointsRedeemed
          : pointsRedeemed // ignore: cast_nullable_to_non_nullable
              as int,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItemModel>,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as OrderAddressModel?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedReadyAt: freezed == estimatedReadyAt
          ? _value.estimatedReadyAt
          : estimatedReadyAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl implements _OrderModel {
  const _$OrderModelImpl(
      {required this.id,
      required this.status,
      required this.subtotal,
      required this.deliveryFee,
      required this.discount,
      required this.loyaltyDiscount,
      required this.total,
      required this.pointsEarned,
      required this.pointsRedeemed,
      required this.paymentMethod,
      final List<OrderItemModel> items = const [],
      this.address,
      this.notes,
      this.estimatedReadyAt,
      required this.createdAt})
      : _items = items;

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
  @override
  final double subtotal;
  @override
  final double deliveryFee;
  @override
  final double discount;
  @override
  final double loyaltyDiscount;
  @override
  final double total;
  @override
  final int pointsEarned;
  @override
  final int pointsRedeemed;
  @override
  final String paymentMethod;
  final List<OrderItemModel> _items;
  @override
  @JsonKey()
  List<OrderItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final OrderAddressModel? address;
  @override
  final String? notes;
  @override
  final DateTime? estimatedReadyAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, subtotal: $subtotal, deliveryFee: $deliveryFee, discount: $discount, loyaltyDiscount: $loyaltyDiscount, total: $total, pointsEarned: $pointsEarned, pointsRedeemed: $pointsRedeemed, paymentMethod: $paymentMethod, items: $items, address: $address, notes: $notes, estimatedReadyAt: $estimatedReadyAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.loyaltyDiscount, loyaltyDiscount) ||
                other.loyaltyDiscount == loyaltyDiscount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.pointsEarned, pointsEarned) ||
                other.pointsEarned == pointsEarned) &&
            (identical(other.pointsRedeemed, pointsRedeemed) ||
                other.pointsRedeemed == pointsRedeemed) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.estimatedReadyAt, estimatedReadyAt) ||
                other.estimatedReadyAt == estimatedReadyAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      status,
      subtotal,
      deliveryFee,
      discount,
      loyaltyDiscount,
      total,
      pointsEarned,
      pointsRedeemed,
      paymentMethod,
      const DeepCollectionEquality().hash(_items),
      address,
      notes,
      estimatedReadyAt,
      createdAt);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(
      this,
    );
  }
}

abstract class _OrderModel implements OrderModel {
  const factory _OrderModel(
      {required final String id,
      required final String status,
      required final double subtotal,
      required final double deliveryFee,
      required final double discount,
      required final double loyaltyDiscount,
      required final double total,
      required final int pointsEarned,
      required final int pointsRedeemed,
      required final String paymentMethod,
      final List<OrderItemModel> items,
      final OrderAddressModel? address,
      final String? notes,
      final DateTime? estimatedReadyAt,
      required final DateTime createdAt}) = _$OrderModelImpl;

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  double get subtotal;
  @override
  double get deliveryFee;
  @override
  double get discount;
  @override
  double get loyaltyDiscount;
  @override
  double get total;
  @override
  int get pointsEarned;
  @override
  int get pointsRedeemed;
  @override
  String get paymentMethod;
  @override
  List<OrderItemModel> get items;
  @override
  OrderAddressModel? get address;
  @override
  String? get notes;
  @override
  DateTime? get estimatedReadyAt;
  @override
  DateTime get createdAt;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) {
  return _OrderItemModel.fromJson(json);
}

/// @nodoc
mixin _$OrderItemModel {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String get productImage => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  List<SelectedModifierModel> get modifiers =>
      throw _privateConstructorUsedError;
  bool? get hasReview => throw _privateConstructorUsedError;

  /// Serializes this OrderItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemModelCopyWith<OrderItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemModelCopyWith<$Res> {
  factory $OrderItemModelCopyWith(
          OrderItemModel value, $Res Function(OrderItemModel) then) =
      _$OrderItemModelCopyWithImpl<$Res, OrderItemModel>;
  @useResult
  $Res call(
      {String id,
      String productId,
      String productName,
      String productImage,
      double unitPrice,
      int quantity,
      double subtotal,
      List<SelectedModifierModel> modifiers,
      bool? hasReview});
}

/// @nodoc
class _$OrderItemModelCopyWithImpl<$Res, $Val extends OrderItemModel>
    implements $OrderItemModelCopyWith<$Res> {
  _$OrderItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? productName = null,
    Object? productImage = null,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? subtotal = null,
    Object? modifiers = null,
    Object? hasReview = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productImage: null == productImage
          ? _value.productImage
          : productImage // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      modifiers: null == modifiers
          ? _value.modifiers
          : modifiers // ignore: cast_nullable_to_non_nullable
              as List<SelectedModifierModel>,
      hasReview: freezed == hasReview
          ? _value.hasReview
          : hasReview // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderItemModelImplCopyWith<$Res>
    implements $OrderItemModelCopyWith<$Res> {
  factory _$$OrderItemModelImplCopyWith(_$OrderItemModelImpl value,
          $Res Function(_$OrderItemModelImpl) then) =
      __$$OrderItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      String productName,
      String productImage,
      double unitPrice,
      int quantity,
      double subtotal,
      List<SelectedModifierModel> modifiers,
      bool? hasReview});
}

/// @nodoc
class __$$OrderItemModelImplCopyWithImpl<$Res>
    extends _$OrderItemModelCopyWithImpl<$Res, _$OrderItemModelImpl>
    implements _$$OrderItemModelImplCopyWith<$Res> {
  __$$OrderItemModelImplCopyWithImpl(
      _$OrderItemModelImpl _value, $Res Function(_$OrderItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? productName = null,
    Object? productImage = null,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? subtotal = null,
    Object? modifiers = null,
    Object? hasReview = freezed,
  }) {
    return _then(_$OrderItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productImage: null == productImage
          ? _value.productImage
          : productImage // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      modifiers: null == modifiers
          ? _value._modifiers
          : modifiers // ignore: cast_nullable_to_non_nullable
              as List<SelectedModifierModel>,
      hasReview: freezed == hasReview
          ? _value.hasReview
          : hasReview // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemModelImpl implements _OrderItemModel {
  const _$OrderItemModelImpl(
      {required this.id,
      required this.productId,
      required this.productName,
      required this.productImage,
      required this.unitPrice,
      required this.quantity,
      required this.subtotal,
      final List<SelectedModifierModel> modifiers =
          const <SelectedModifierModel>[],
      this.hasReview})
      : _modifiers = modifiers;

  factory _$OrderItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemModelImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final String productImage;
  @override
  final double unitPrice;
  @override
  final int quantity;
  @override
  final double subtotal;
  final List<SelectedModifierModel> _modifiers;
  @override
  @JsonKey()
  List<SelectedModifierModel> get modifiers {
    if (_modifiers is EqualUnmodifiableListView) return _modifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modifiers);
  }

  @override
  final bool? hasReview;

  @override
  String toString() {
    return 'OrderItemModel(id: $id, productId: $productId, productName: $productName, productImage: $productImage, unitPrice: $unitPrice, quantity: $quantity, subtotal: $subtotal, modifiers: $modifiers, hasReview: $hasReview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productImage, productImage) ||
                other.productImage == productImage) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            const DeepCollectionEquality()
                .equals(other._modifiers, _modifiers) &&
            (identical(other.hasReview, hasReview) ||
                other.hasReview == hasReview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      productId,
      productName,
      productImage,
      unitPrice,
      quantity,
      subtotal,
      const DeepCollectionEquality().hash(_modifiers),
      hasReview);

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemModelImplCopyWith<_$OrderItemModelImpl> get copyWith =>
      __$$OrderItemModelImplCopyWithImpl<_$OrderItemModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemModelImplToJson(
      this,
    );
  }
}

abstract class _OrderItemModel implements OrderItemModel {
  const factory _OrderItemModel(
      {required final String id,
      required final String productId,
      required final String productName,
      required final String productImage,
      required final double unitPrice,
      required final int quantity,
      required final double subtotal,
      final List<SelectedModifierModel> modifiers,
      final bool? hasReview}) = _$OrderItemModelImpl;

  factory _OrderItemModel.fromJson(Map<String, dynamic> json) =
      _$OrderItemModelImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  String get productName;
  @override
  String get productImage;
  @override
  double get unitPrice;
  @override
  int get quantity;
  @override
  double get subtotal;
  @override
  List<SelectedModifierModel> get modifiers;
  @override
  bool? get hasReview;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemModelImplCopyWith<_$OrderItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderAddressModel _$OrderAddressModelFromJson(Map<String, dynamic> json) {
  return _OrderAddressModel.fromJson(json);
}

/// @nodoc
mixin _$OrderAddressModel {
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get street => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get postalCode => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;

  /// Serializes this OrderAddressModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderAddressModelCopyWith<OrderAddressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderAddressModelCopyWith<$Res> {
  factory $OrderAddressModelCopyWith(
          OrderAddressModel value, $Res Function(OrderAddressModel) then) =
      _$OrderAddressModelCopyWithImpl<$Res, OrderAddressModel>;
  @useResult
  $Res call(
      {String fullName,
      String phone,
      String street,
      String city,
      String state,
      String postalCode,
      String country,
      String? label});
}

/// @nodoc
class _$OrderAddressModelCopyWithImpl<$Res, $Val extends OrderAddressModel>
    implements $OrderAddressModelCopyWith<$Res> {
  _$OrderAddressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? phone = null,
    Object? street = null,
    Object? city = null,
    Object? state = null,
    Object? postalCode = null,
    Object? country = null,
    Object? label = freezed,
  }) {
    return _then(_value.copyWith(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      postalCode: null == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderAddressModelImplCopyWith<$Res>
    implements $OrderAddressModelCopyWith<$Res> {
  factory _$$OrderAddressModelImplCopyWith(_$OrderAddressModelImpl value,
          $Res Function(_$OrderAddressModelImpl) then) =
      __$$OrderAddressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fullName,
      String phone,
      String street,
      String city,
      String state,
      String postalCode,
      String country,
      String? label});
}

/// @nodoc
class __$$OrderAddressModelImplCopyWithImpl<$Res>
    extends _$OrderAddressModelCopyWithImpl<$Res, _$OrderAddressModelImpl>
    implements _$$OrderAddressModelImplCopyWith<$Res> {
  __$$OrderAddressModelImplCopyWithImpl(_$OrderAddressModelImpl _value,
      $Res Function(_$OrderAddressModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? phone = null,
    Object? street = null,
    Object? city = null,
    Object? state = null,
    Object? postalCode = null,
    Object? country = null,
    Object? label = freezed,
  }) {
    return _then(_$OrderAddressModelImpl(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      postalCode: null == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderAddressModelImpl implements _OrderAddressModel {
  const _$OrderAddressModelImpl(
      {required this.fullName,
      required this.phone,
      required this.street,
      required this.city,
      required this.state,
      required this.postalCode,
      required this.country,
      this.label});

  factory _$OrderAddressModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderAddressModelImplFromJson(json);

  @override
  final String fullName;
  @override
  final String phone;
  @override
  final String street;
  @override
  final String city;
  @override
  final String state;
  @override
  final String postalCode;
  @override
  final String country;
  @override
  final String? label;

  @override
  String toString() {
    return 'OrderAddressModel(fullName: $fullName, phone: $phone, street: $street, city: $city, state: $state, postalCode: $postalCode, country: $country, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderAddressModelImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fullName, phone, street, city,
      state, postalCode, country, label);

  /// Create a copy of OrderAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderAddressModelImplCopyWith<_$OrderAddressModelImpl> get copyWith =>
      __$$OrderAddressModelImplCopyWithImpl<_$OrderAddressModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderAddressModelImplToJson(
      this,
    );
  }
}

abstract class _OrderAddressModel implements OrderAddressModel {
  const factory _OrderAddressModel(
      {required final String fullName,
      required final String phone,
      required final String street,
      required final String city,
      required final String state,
      required final String postalCode,
      required final String country,
      final String? label}) = _$OrderAddressModelImpl;

  factory _OrderAddressModel.fromJson(Map<String, dynamic> json) =
      _$OrderAddressModelImpl.fromJson;

  @override
  String get fullName;
  @override
  String get phone;
  @override
  String get street;
  @override
  String get city;
  @override
  String get state;
  @override
  String get postalCode;
  @override
  String get country;
  @override
  String? get label;

  /// Create a copy of OrderAddressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderAddressModelImplCopyWith<_$OrderAddressModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
