// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) {
  return _CartItemModel.fromJson(json);
}

/// @nodoc
mixin _$CartItemModel {
  String get id => throw _privateConstructorUsedError;
  int get quantity =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: numToDouble)
  double get unitPrice => throw _privateConstructorUsedError;
  List<SelectedModifierModel> get modifiers =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
  ProductModel get product => throw _privateConstructorUsedError;

  /// Serializes this CartItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemModelCopyWith<CartItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemModelCopyWith<$Res> {
  factory $CartItemModelCopyWith(
          CartItemModel value, $Res Function(CartItemModel) then) =
      _$CartItemModelCopyWithImpl<$Res, CartItemModel>;
  @useResult
  $Res call(
      {String id,
      int quantity,
      @JsonKey(fromJson: numToDouble) double unitPrice,
      List<SelectedModifierModel> modifiers,
      @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
      ProductModel product});

  $ProductModelCopyWith<$Res> get product;
}

/// @nodoc
class _$CartItemModelCopyWithImpl<$Res, $Val extends CartItemModel>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? modifiers = null,
    Object? product = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      modifiers: null == modifiers
          ? _value.modifiers
          : modifiers // ignore: cast_nullable_to_non_nullable
              as List<SelectedModifierModel>,
      product: null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel,
    ) as $Val);
  }

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductModelCopyWith<$Res> get product {
    return $ProductModelCopyWith<$Res>(_value.product, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartItemModelImplCopyWith<$Res>
    implements $CartItemModelCopyWith<$Res> {
  factory _$$CartItemModelImplCopyWith(
          _$CartItemModelImpl value, $Res Function(_$CartItemModelImpl) then) =
      __$$CartItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int quantity,
      @JsonKey(fromJson: numToDouble) double unitPrice,
      List<SelectedModifierModel> modifiers,
      @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
      ProductModel product});

  @override
  $ProductModelCopyWith<$Res> get product;
}

/// @nodoc
class __$$CartItemModelImplCopyWithImpl<$Res>
    extends _$CartItemModelCopyWithImpl<$Res, _$CartItemModelImpl>
    implements _$$CartItemModelImplCopyWith<$Res> {
  __$$CartItemModelImplCopyWithImpl(
      _$CartItemModelImpl _value, $Res Function(_$CartItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? modifiers = null,
    Object? product = null,
  }) {
    return _then(_$CartItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      modifiers: null == modifiers
          ? _value._modifiers
          : modifiers // ignore: cast_nullable_to_non_nullable
              as List<SelectedModifierModel>,
      product: null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemModelImpl extends _CartItemModel {
  const _$CartItemModelImpl(
      {required this.id,
      required this.quantity,
      @JsonKey(fromJson: numToDouble) this.unitPrice = 0.0,
      final List<SelectedModifierModel> modifiers =
          const <SelectedModifierModel>[],
      @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
      required this.product})
      : _modifiers = modifiers,
        super._();

  factory _$CartItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemModelImplFromJson(json);

  @override
  final String id;
  @override
  final int quantity;
// ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: numToDouble)
  final double unitPrice;
  final List<SelectedModifierModel> _modifiers;
  @override
  @JsonKey()
  List<SelectedModifierModel> get modifiers {
    if (_modifiers is EqualUnmodifiableListView) return _modifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modifiers);
  }

// ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
  final ProductModel product;

  @override
  String toString() {
    return 'CartItemModel(id: $id, quantity: $quantity, unitPrice: $unitPrice, modifiers: $modifiers, product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            const DeepCollectionEquality()
                .equals(other._modifiers, _modifiers) &&
            (identical(other.product, product) || other.product == product));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, quantity, unitPrice,
      const DeepCollectionEquality().hash(_modifiers), product);

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      __$$CartItemModelImplCopyWithImpl<_$CartItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemModelImplToJson(
      this,
    );
  }
}

abstract class _CartItemModel extends CartItemModel {
  const factory _CartItemModel(
      {required final String id,
      required final int quantity,
      @JsonKey(fromJson: numToDouble) final double unitPrice,
      final List<SelectedModifierModel> modifiers,
      @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
      required final ProductModel product}) = _$CartItemModelImpl;
  const _CartItemModel._() : super._();

  factory _CartItemModel.fromJson(Map<String, dynamic> json) =
      _$CartItemModelImpl.fromJson;

  @override
  String get id;
  @override
  int get quantity; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: numToDouble)
  double get unitPrice;
  @override
  List<SelectedModifierModel>
      get modifiers; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
  ProductModel get product;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
