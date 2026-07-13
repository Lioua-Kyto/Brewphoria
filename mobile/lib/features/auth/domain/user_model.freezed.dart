// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get firebaseUid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String id,
      String firebaseUid,
      String email,
      String displayName,
      String? firstName,
      String? lastName,
      String? avatarUrl,
      String role,
      DateTime createdAt});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firebaseUid = null,
    Object? email = null,
    Object? displayName = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firebaseUid: null == firebaseUid
          ? _value.firebaseUid
          : firebaseUid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String firebaseUid,
      String email,
      String displayName,
      String? firstName,
      String? lastName,
      String? avatarUrl,
      String role,
      DateTime createdAt});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firebaseUid = null,
    Object? email = null,
    Object? displayName = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? createdAt = null,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firebaseUid: null == firebaseUid
          ? _value.firebaseUid
          : firebaseUid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
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
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl(
      {required this.id,
      required this.firebaseUid,
      required this.email,
      required this.displayName,
      this.firstName,
      this.lastName,
      this.avatarUrl,
      this.role = 'USER',
      required this.createdAt})
      : super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String firebaseUid;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final String role;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'UserModel(id: $id, firebaseUid: $firebaseUid, email: $email, displayName: $displayName, firstName: $firstName, lastName: $lastName, avatarUrl: $avatarUrl, role: $role, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firebaseUid, firebaseUid) ||
                other.firebaseUid == firebaseUid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firebaseUid, email,
      displayName, firstName, lastName, avatarUrl, role, createdAt);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
      {required final String id,
      required final String firebaseUid,
      required final String email,
      required final String displayName,
      final String? firstName,
      final String? lastName,
      final String? avatarUrl,
      final String role,
      required final DateTime createdAt}) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get firebaseUid;
  @override
  String get email;
  @override
  String get displayName;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get avatarUrl;
  @override
  String get role;
  @override
  DateTime get createdAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoyaltySummary _$LoyaltySummaryFromJson(Map<String, dynamic> json) {
  return _LoyaltySummary.fromJson(json);
}

/// @nodoc
mixin _$LoyaltySummary {
  int get currentPoints => throw _privateConstructorUsedError;
  int get lifetimePoints => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;

  /// Serializes this LoyaltySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltySummaryCopyWith<LoyaltySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltySummaryCopyWith<$Res> {
  factory $LoyaltySummaryCopyWith(
          LoyaltySummary value, $Res Function(LoyaltySummary) then) =
      _$LoyaltySummaryCopyWithImpl<$Res, LoyaltySummary>;
  @useResult
  $Res call({int currentPoints, int lifetimePoints, String tier});
}

/// @nodoc
class _$LoyaltySummaryCopyWithImpl<$Res, $Val extends LoyaltySummary>
    implements $LoyaltySummaryCopyWith<$Res> {
  _$LoyaltySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPoints = null,
    Object? lifetimePoints = null,
    Object? tier = null,
  }) {
    return _then(_value.copyWith(
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
abstract class _$$LoyaltySummaryImplCopyWith<$Res>
    implements $LoyaltySummaryCopyWith<$Res> {
  factory _$$LoyaltySummaryImplCopyWith(_$LoyaltySummaryImpl value,
          $Res Function(_$LoyaltySummaryImpl) then) =
      __$$LoyaltySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentPoints, int lifetimePoints, String tier});
}

/// @nodoc
class __$$LoyaltySummaryImplCopyWithImpl<$Res>
    extends _$LoyaltySummaryCopyWithImpl<$Res, _$LoyaltySummaryImpl>
    implements _$$LoyaltySummaryImplCopyWith<$Res> {
  __$$LoyaltySummaryImplCopyWithImpl(
      _$LoyaltySummaryImpl _value, $Res Function(_$LoyaltySummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoyaltySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPoints = null,
    Object? lifetimePoints = null,
    Object? tier = null,
  }) {
    return _then(_$LoyaltySummaryImpl(
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
class _$LoyaltySummaryImpl implements _LoyaltySummary {
  const _$LoyaltySummaryImpl(
      {required this.currentPoints,
      required this.lifetimePoints,
      required this.tier});

  factory _$LoyaltySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltySummaryImplFromJson(json);

  @override
  final int currentPoints;
  @override
  final int lifetimePoints;
  @override
  final String tier;

  @override
  String toString() {
    return 'LoyaltySummary(currentPoints: $currentPoints, lifetimePoints: $lifetimePoints, tier: $tier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltySummaryImpl &&
            (identical(other.currentPoints, currentPoints) ||
                other.currentPoints == currentPoints) &&
            (identical(other.lifetimePoints, lifetimePoints) ||
                other.lifetimePoints == lifetimePoints) &&
            (identical(other.tier, tier) || other.tier == tier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentPoints, lifetimePoints, tier);

  /// Create a copy of LoyaltySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltySummaryImplCopyWith<_$LoyaltySummaryImpl> get copyWith =>
      __$$LoyaltySummaryImplCopyWithImpl<_$LoyaltySummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltySummaryImplToJson(
      this,
    );
  }
}

abstract class _LoyaltySummary implements LoyaltySummary {
  const factory _LoyaltySummary(
      {required final int currentPoints,
      required final int lifetimePoints,
      required final String tier}) = _$LoyaltySummaryImpl;

  factory _LoyaltySummary.fromJson(Map<String, dynamic> json) =
      _$LoyaltySummaryImpl.fromJson;

  @override
  int get currentPoints;
  @override
  int get lifetimePoints;
  @override
  String get tier;

  /// Create a copy of LoyaltySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltySummaryImplCopyWith<_$LoyaltySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _LoginResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginResponse {
  UserModel get user => throw _privateConstructorUsedError;
  LoyaltySummary get loyaltySummary => throw _privateConstructorUsedError;

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseCopyWith<LoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseCopyWith<$Res> {
  factory $LoginResponseCopyWith(
          LoginResponse value, $Res Function(LoginResponse) then) =
      _$LoginResponseCopyWithImpl<$Res, LoginResponse>;
  @useResult
  $Res call({UserModel user, LoyaltySummary loyaltySummary});

  $UserModelCopyWith<$Res> get user;
  $LoyaltySummaryCopyWith<$Res> get loyaltySummary;
}

/// @nodoc
class _$LoginResponseCopyWithImpl<$Res, $Val extends LoginResponse>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? loyaltySummary = null,
  }) {
    return _then(_value.copyWith(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      loyaltySummary: null == loyaltySummary
          ? _value.loyaltySummary
          : loyaltySummary // ignore: cast_nullable_to_non_nullable
              as LoyaltySummary,
    ) as $Val);
  }

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LoyaltySummaryCopyWith<$Res> get loyaltySummary {
    return $LoyaltySummaryCopyWith<$Res>(_value.loyaltySummary, (value) {
      return _then(_value.copyWith(loyaltySummary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginResponseImplCopyWith<$Res>
    implements $LoginResponseCopyWith<$Res> {
  factory _$$LoginResponseImplCopyWith(
          _$LoginResponseImpl value, $Res Function(_$LoginResponseImpl) then) =
      __$$LoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserModel user, LoyaltySummary loyaltySummary});

  @override
  $UserModelCopyWith<$Res> get user;
  @override
  $LoyaltySummaryCopyWith<$Res> get loyaltySummary;
}

/// @nodoc
class __$$LoginResponseImplCopyWithImpl<$Res>
    extends _$LoginResponseCopyWithImpl<$Res, _$LoginResponseImpl>
    implements _$$LoginResponseImplCopyWith<$Res> {
  __$$LoginResponseImplCopyWithImpl(
      _$LoginResponseImpl _value, $Res Function(_$LoginResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? loyaltySummary = null,
  }) {
    return _then(_$LoginResponseImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      loyaltySummary: null == loyaltySummary
          ? _value.loyaltySummary
          : loyaltySummary // ignore: cast_nullable_to_non_nullable
              as LoyaltySummary,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseImpl implements _LoginResponse {
  const _$LoginResponseImpl({required this.user, required this.loyaltySummary});

  factory _$LoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseImplFromJson(json);

  @override
  final UserModel user;
  @override
  final LoyaltySummary loyaltySummary;

  @override
  String toString() {
    return 'LoginResponse(user: $user, loyaltySummary: $loyaltySummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.loyaltySummary, loyaltySummary) ||
                other.loyaltySummary == loyaltySummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, loyaltySummary);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      __$$LoginResponseImplCopyWithImpl<_$LoginResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseImplToJson(
      this,
    );
  }
}

abstract class _LoginResponse implements LoginResponse {
  const factory _LoginResponse(
      {required final UserModel user,
      required final LoyaltySummary loyaltySummary}) = _$LoginResponseImpl;

  factory _LoginResponse.fromJson(Map<String, dynamic> json) =
      _$LoginResponseImpl.fromJson;

  @override
  UserModel get user;
  @override
  LoyaltySummary get loyaltySummary;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
