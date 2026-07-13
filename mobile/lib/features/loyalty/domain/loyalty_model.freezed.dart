// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loyalty_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoyaltyModel _$LoyaltyModelFromJson(Map<String, dynamic> json) {
  return _LoyaltyModel.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyModel {
  String get id => throw _privateConstructorUsedError;
  int get currentPoints => throw _privateConstructorUsedError;
  int get lifetimePoints => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyModelCopyWith<LoyaltyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyModelCopyWith<$Res> {
  factory $LoyaltyModelCopyWith(
          LoyaltyModel value, $Res Function(LoyaltyModel) then) =
      _$LoyaltyModelCopyWithImpl<$Res, LoyaltyModel>;
  @useResult
  $Res call({String id, int currentPoints, int lifetimePoints, String tier});
}

/// @nodoc
class _$LoyaltyModelCopyWithImpl<$Res, $Val extends LoyaltyModel>
    implements $LoyaltyModelCopyWith<$Res> {
  _$LoyaltyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? currentPoints = null,
    Object? lifetimePoints = null,
    Object? tier = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      currentPoints: null == currentPoints
          ? _value.currentPoints
          : currentPoints // ignore: cast_nullable_to_non_nullable
              as int,
      lifetimePoints: null == lifetimePoints
          ? _value.lifetimePoints
          : lifetimePoints // ignore: cast_nullable_to_non_nullable
              as int,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoyaltyModelImplCopyWith<$Res>
    implements $LoyaltyModelCopyWith<$Res> {
  factory _$$LoyaltyModelImplCopyWith(
          _$LoyaltyModelImpl value, $Res Function(_$LoyaltyModelImpl) then) =
      __$$LoyaltyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int currentPoints, int lifetimePoints, String tier});
}

/// @nodoc
class __$$LoyaltyModelImplCopyWithImpl<$Res>
    extends _$LoyaltyModelCopyWithImpl<$Res, _$LoyaltyModelImpl>
    implements _$$LoyaltyModelImplCopyWith<$Res> {
  __$$LoyaltyModelImplCopyWithImpl(
      _$LoyaltyModelImpl _value, $Res Function(_$LoyaltyModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoyaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? currentPoints = null,
    Object? lifetimePoints = null,
    Object? tier = null,
  }) {
    return _then(_$LoyaltyModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      currentPoints: null == currentPoints
          ? _value.currentPoints
          : currentPoints // ignore: cast_nullable_to_non_nullable
              as int,
      lifetimePoints: null == lifetimePoints
          ? _value.lifetimePoints
          : lifetimePoints // ignore: cast_nullable_to_non_nullable
              as int,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoyaltyModelImpl implements _LoyaltyModel {
  const _$LoyaltyModelImpl(
      {required this.id,
      required this.currentPoints,
      required this.lifetimePoints,
      required this.tier});

  factory _$LoyaltyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyModelImplFromJson(json);

  @override
  final String id;
  @override
  final int currentPoints;
  @override
  final int lifetimePoints;
  @override
  final String tier;

  @override
  String toString() {
    return 'LoyaltyModel(id: $id, currentPoints: $currentPoints, lifetimePoints: $lifetimePoints, tier: $tier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.currentPoints, currentPoints) ||
                other.currentPoints == currentPoints) &&
            (identical(other.lifetimePoints, lifetimePoints) ||
                other.lifetimePoints == lifetimePoints) &&
            (identical(other.tier, tier) || other.tier == tier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, currentPoints, lifetimePoints, tier);

  /// Create a copy of LoyaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyModelImplCopyWith<_$LoyaltyModelImpl> get copyWith =>
      __$$LoyaltyModelImplCopyWithImpl<_$LoyaltyModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyModelImplToJson(
      this,
    );
  }
}

abstract class _LoyaltyModel implements LoyaltyModel {
  const factory _LoyaltyModel(
      {required final String id,
      required final int currentPoints,
      required final int lifetimePoints,
      required final String tier}) = _$LoyaltyModelImpl;

  factory _LoyaltyModel.fromJson(Map<String, dynamic> json) =
      _$LoyaltyModelImpl.fromJson;

  @override
  String get id;
  @override
  int get currentPoints;
  @override
  int get lifetimePoints;
  @override
  String get tier;

  /// Create a copy of LoyaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyModelImplCopyWith<_$LoyaltyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoyaltyTransactionModel _$LoyaltyTransactionModelFromJson(
    Map<String, dynamic> json) {
  return _LoyaltyTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyTransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyTransactionModelCopyWith<LoyaltyTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyTransactionModelCopyWith<$Res> {
  factory $LoyaltyTransactionModelCopyWith(LoyaltyTransactionModel value,
          $Res Function(LoyaltyTransactionModel) then) =
      _$LoyaltyTransactionModelCopyWithImpl<$Res, LoyaltyTransactionModel>;
  @useResult
  $Res call(
      {String id,
      String type,
      int points,
      String description,
      DateTime createdAt});
}

/// @nodoc
class _$LoyaltyTransactionModelCopyWithImpl<$Res,
        $Val extends LoyaltyTransactionModel>
    implements $LoyaltyTransactionModelCopyWith<$Res> {
  _$LoyaltyTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? points = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoyaltyTransactionModelImplCopyWith<$Res>
    implements $LoyaltyTransactionModelCopyWith<$Res> {
  factory _$$LoyaltyTransactionModelImplCopyWith(
          _$LoyaltyTransactionModelImpl value,
          $Res Function(_$LoyaltyTransactionModelImpl) then) =
      __$$LoyaltyTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      int points,
      String description,
      DateTime createdAt});
}

/// @nodoc
class __$$LoyaltyTransactionModelImplCopyWithImpl<$Res>
    extends _$LoyaltyTransactionModelCopyWithImpl<$Res,
        _$LoyaltyTransactionModelImpl>
    implements _$$LoyaltyTransactionModelImplCopyWith<$Res> {
  __$$LoyaltyTransactionModelImplCopyWithImpl(
      _$LoyaltyTransactionModelImpl _value,
      $Res Function(_$LoyaltyTransactionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? points = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(_$LoyaltyTransactionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoyaltyTransactionModelImpl implements _LoyaltyTransactionModel {
  const _$LoyaltyTransactionModelImpl(
      {required this.id,
      required this.type,
      required this.points,
      required this.description,
      required this.createdAt});

  factory _$LoyaltyTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyTransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final int points;
  @override
  final String description;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LoyaltyTransactionModel(id: $id, type: $type, points: $points, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, points, description, createdAt);

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyTransactionModelImplCopyWith<_$LoyaltyTransactionModelImpl>
      get copyWith => __$$LoyaltyTransactionModelImplCopyWithImpl<
          _$LoyaltyTransactionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyTransactionModelImplToJson(
      this,
    );
  }
}

abstract class _LoyaltyTransactionModel implements LoyaltyTransactionModel {
  const factory _LoyaltyTransactionModel(
      {required final String id,
      required final String type,
      required final int points,
      required final String description,
      required final DateTime createdAt}) = _$LoyaltyTransactionModelImpl;

  factory _LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) =
      _$LoyaltyTransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  int get points;
  @override
  String get description;
  @override
  DateTime get createdAt;

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyTransactionModelImplCopyWith<_$LoyaltyTransactionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RedemptionValidation _$RedemptionValidationFromJson(Map<String, dynamic> json) {
  return _RedemptionValidation.fromJson(json);
}

/// @nodoc
mixin _$RedemptionValidation {
  int get pointsToRedeem => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  int get remainingPoints => throw _privateConstructorUsedError;

  /// Serializes this RedemptionValidation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedemptionValidation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedemptionValidationCopyWith<RedemptionValidation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedemptionValidationCopyWith<$Res> {
  factory $RedemptionValidationCopyWith(RedemptionValidation value,
          $Res Function(RedemptionValidation) then) =
      _$RedemptionValidationCopyWithImpl<$Res, RedemptionValidation>;
  @useResult
  $Res call({int pointsToRedeem, double discountAmount, int remainingPoints});
}

/// @nodoc
class _$RedemptionValidationCopyWithImpl<$Res,
        $Val extends RedemptionValidation>
    implements $RedemptionValidationCopyWith<$Res> {
  _$RedemptionValidationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedemptionValidation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pointsToRedeem = null,
    Object? discountAmount = null,
    Object? remainingPoints = null,
  }) {
    return _then(_value.copyWith(
      pointsToRedeem: null == pointsToRedeem
          ? _value.pointsToRedeem
          : pointsToRedeem // ignore: cast_nullable_to_non_nullable
              as int,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      remainingPoints: null == remainingPoints
          ? _value.remainingPoints
          : remainingPoints // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedemptionValidationImplCopyWith<$Res>
    implements $RedemptionValidationCopyWith<$Res> {
  factory _$$RedemptionValidationImplCopyWith(_$RedemptionValidationImpl value,
          $Res Function(_$RedemptionValidationImpl) then) =
      __$$RedemptionValidationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int pointsToRedeem, double discountAmount, int remainingPoints});
}

/// @nodoc
class __$$RedemptionValidationImplCopyWithImpl<$Res>
    extends _$RedemptionValidationCopyWithImpl<$Res, _$RedemptionValidationImpl>
    implements _$$RedemptionValidationImplCopyWith<$Res> {
  __$$RedemptionValidationImplCopyWithImpl(_$RedemptionValidationImpl _value,
      $Res Function(_$RedemptionValidationImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedemptionValidation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pointsToRedeem = null,
    Object? discountAmount = null,
    Object? remainingPoints = null,
  }) {
    return _then(_$RedemptionValidationImpl(
      pointsToRedeem: null == pointsToRedeem
          ? _value.pointsToRedeem
          : pointsToRedeem // ignore: cast_nullable_to_non_nullable
              as int,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      remainingPoints: null == remainingPoints
          ? _value.remainingPoints
          : remainingPoints // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedemptionValidationImpl implements _RedemptionValidation {
  const _$RedemptionValidationImpl(
      {required this.pointsToRedeem,
      required this.discountAmount,
      required this.remainingPoints});

  factory _$RedemptionValidationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedemptionValidationImplFromJson(json);

  @override
  final int pointsToRedeem;
  @override
  final double discountAmount;
  @override
  final int remainingPoints;

  @override
  String toString() {
    return 'RedemptionValidation(pointsToRedeem: $pointsToRedeem, discountAmount: $discountAmount, remainingPoints: $remainingPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedemptionValidationImpl &&
            (identical(other.pointsToRedeem, pointsToRedeem) ||
                other.pointsToRedeem == pointsToRedeem) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.remainingPoints, remainingPoints) ||
                other.remainingPoints == remainingPoints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, pointsToRedeem, discountAmount, remainingPoints);

  /// Create a copy of RedemptionValidation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedemptionValidationImplCopyWith<_$RedemptionValidationImpl>
      get copyWith =>
          __$$RedemptionValidationImplCopyWithImpl<_$RedemptionValidationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedemptionValidationImplToJson(
      this,
    );
  }
}

abstract class _RedemptionValidation implements RedemptionValidation {
  const factory _RedemptionValidation(
      {required final int pointsToRedeem,
      required final double discountAmount,
      required final int remainingPoints}) = _$RedemptionValidationImpl;

  factory _RedemptionValidation.fromJson(Map<String, dynamic> json) =
      _$RedemptionValidationImpl.fromJson;

  @override
  int get pointsToRedeem;
  @override
  double get discountAmount;
  @override
  int get remainingPoints;

  /// Create a copy of RedemptionValidation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedemptionValidationImplCopyWith<_$RedemptionValidationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
