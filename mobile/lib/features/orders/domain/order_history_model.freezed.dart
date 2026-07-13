// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckoutRequest _$CheckoutRequestFromJson(Map<String, dynamic> json) {
  return _CheckoutRequest.fromJson(json);
}

/// @nodoc
mixin _$CheckoutRequest {
  String get addressId => throw _privateConstructorUsedError;
  int get pointsToRedeem => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double get tip => throw _privateConstructorUsedError;

  /// Serializes this CheckoutRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckoutRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckoutRequestCopyWith<CheckoutRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutRequestCopyWith<$Res> {
  factory $CheckoutRequestCopyWith(
          CheckoutRequest value, $Res Function(CheckoutRequest) then) =
      _$CheckoutRequestCopyWithImpl<$Res, CheckoutRequest>;
  @useResult
  $Res call(
      {String addressId,
      int pointsToRedeem,
      String paymentMethod,
      String? notes,
      double tip});
}

/// @nodoc
class _$CheckoutRequestCopyWithImpl<$Res, $Val extends CheckoutRequest>
    implements $CheckoutRequestCopyWith<$Res> {
  _$CheckoutRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckoutRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressId = null,
    Object? pointsToRedeem = null,
    Object? paymentMethod = null,
    Object? notes = freezed,
    Object? tip = null,
  }) {
    return _then(_value.copyWith(
      addressId: null == addressId
          ? _value.addressId
          : addressId // ignore: cast_nullable_to_non_nullable
              as String,
      pointsToRedeem: null == pointsToRedeem
          ? _value.pointsToRedeem
          : pointsToRedeem // ignore: cast_nullable_to_non_nullable
              as int,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tip: null == tip
          ? _value.tip
          : tip // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckoutRequestImplCopyWith<$Res>
    implements $CheckoutRequestCopyWith<$Res> {
  factory _$$CheckoutRequestImplCopyWith(_$CheckoutRequestImpl value,
          $Res Function(_$CheckoutRequestImpl) then) =
      __$$CheckoutRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String addressId,
      int pointsToRedeem,
      String paymentMethod,
      String? notes,
      double tip});
}

/// @nodoc
class __$$CheckoutRequestImplCopyWithImpl<$Res>
    extends _$CheckoutRequestCopyWithImpl<$Res, _$CheckoutRequestImpl>
    implements _$$CheckoutRequestImplCopyWith<$Res> {
  __$$CheckoutRequestImplCopyWithImpl(
      _$CheckoutRequestImpl _value, $Res Function(_$CheckoutRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckoutRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressId = null,
    Object? pointsToRedeem = null,
    Object? paymentMethod = null,
    Object? notes = freezed,
    Object? tip = null,
  }) {
    return _then(_$CheckoutRequestImpl(
      addressId: null == addressId
          ? _value.addressId
          : addressId // ignore: cast_nullable_to_non_nullable
              as String,
      pointsToRedeem: null == pointsToRedeem
          ? _value.pointsToRedeem
          : pointsToRedeem // ignore: cast_nullable_to_non_nullable
              as int,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tip: null == tip
          ? _value.tip
          : tip // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckoutRequestImpl implements _CheckoutRequest {
  const _$CheckoutRequestImpl(
      {required this.addressId,
      this.pointsToRedeem = 0,
      this.paymentMethod = 'COD',
      this.notes,
      this.tip = 0.0});

  factory _$CheckoutRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckoutRequestImplFromJson(json);

  @override
  final String addressId;
  @override
  @JsonKey()
  final int pointsToRedeem;
  @override
  @JsonKey()
  final String paymentMethod;
  @override
  final String? notes;
  @override
  @JsonKey()
  final double tip;

  @override
  String toString() {
    return 'CheckoutRequest(addressId: $addressId, pointsToRedeem: $pointsToRedeem, paymentMethod: $paymentMethod, notes: $notes, tip: $tip)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckoutRequestImpl &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.pointsToRedeem, pointsToRedeem) ||
                other.pointsToRedeem == pointsToRedeem) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.tip, tip) || other.tip == tip));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, addressId, pointsToRedeem, paymentMethod, notes, tip);

  /// Create a copy of CheckoutRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckoutRequestImplCopyWith<_$CheckoutRequestImpl> get copyWith =>
      __$$CheckoutRequestImplCopyWithImpl<_$CheckoutRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckoutRequestImplToJson(
      this,
    );
  }
}

abstract class _CheckoutRequest implements CheckoutRequest {
  const factory _CheckoutRequest(
      {required final String addressId,
      final int pointsToRedeem,
      final String paymentMethod,
      final String? notes,
      final double tip}) = _$CheckoutRequestImpl;

  factory _CheckoutRequest.fromJson(Map<String, dynamic> json) =
      _$CheckoutRequestImpl.fromJson;

  @override
  String get addressId;
  @override
  int get pointsToRedeem;
  @override
  String get paymentMethod;
  @override
  String? get notes;
  @override
  double get tip;

  /// Create a copy of CheckoutRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckoutRequestImplCopyWith<_$CheckoutRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
