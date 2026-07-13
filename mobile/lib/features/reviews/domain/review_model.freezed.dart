// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) {
  return _ReviewModel.fromJson(json);
}

/// @nodoc
mixin _$ReviewModel {
  String get id => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  ReviewUserModel? get user => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;

  /// Serializes this ReviewModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewModelCopyWith<ReviewModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewModelCopyWith<$Res> {
  factory $ReviewModelCopyWith(
          ReviewModel value, $Res Function(ReviewModel) then) =
      _$ReviewModelCopyWithImpl<$Res, ReviewModel>;
  @useResult
  $Res call(
      {String id,
      int rating,
      String comment,
      List<String> images,
      DateTime createdAt,
      ReviewUserModel? user,
      String? productId});

  $ReviewUserModelCopyWith<$Res>? get user;
}

/// @nodoc
class _$ReviewModelCopyWithImpl<$Res, $Val extends ReviewModel>
    implements $ReviewModelCopyWith<$Res> {
  _$ReviewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = null,
    Object? images = null,
    Object? createdAt = null,
    Object? user = freezed,
    Object? productId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as ReviewUserModel?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReviewUserModelCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $ReviewUserModelCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReviewModelImplCopyWith<$Res>
    implements $ReviewModelCopyWith<$Res> {
  factory _$$ReviewModelImplCopyWith(
          _$ReviewModelImpl value, $Res Function(_$ReviewModelImpl) then) =
      __$$ReviewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int rating,
      String comment,
      List<String> images,
      DateTime createdAt,
      ReviewUserModel? user,
      String? productId});

  @override
  $ReviewUserModelCopyWith<$Res>? get user;
}

/// @nodoc
class __$$ReviewModelImplCopyWithImpl<$Res>
    extends _$ReviewModelCopyWithImpl<$Res, _$ReviewModelImpl>
    implements _$$ReviewModelImplCopyWith<$Res> {
  __$$ReviewModelImplCopyWithImpl(
      _$ReviewModelImpl _value, $Res Function(_$ReviewModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = null,
    Object? images = null,
    Object? createdAt = null,
    Object? user = freezed,
    Object? productId = freezed,
  }) {
    return _then(_$ReviewModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as ReviewUserModel?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewModelImpl implements _ReviewModel {
  const _$ReviewModelImpl(
      {required this.id,
      required this.rating,
      required this.comment,
      final List<String> images = const [],
      required this.createdAt,
      this.user,
      this.productId})
      : _images = images;

  factory _$ReviewModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewModelImplFromJson(json);

  @override
  final String id;
  @override
  final int rating;
  @override
  final String comment;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final DateTime createdAt;
  @override
  final ReviewUserModel? user;
  @override
  final String? productId;

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, comment: $comment, images: $images, createdAt: $createdAt, user: $user, productId: $productId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.productId, productId) ||
                other.productId == productId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, rating, comment,
      const DeepCollectionEquality().hash(_images), createdAt, user, productId);

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewModelImplCopyWith<_$ReviewModelImpl> get copyWith =>
      __$$ReviewModelImplCopyWithImpl<_$ReviewModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewModelImplToJson(
      this,
    );
  }
}

abstract class _ReviewModel implements ReviewModel {
  const factory _ReviewModel(
      {required final String id,
      required final int rating,
      required final String comment,
      final List<String> images,
      required final DateTime createdAt,
      final ReviewUserModel? user,
      final String? productId}) = _$ReviewModelImpl;

  factory _ReviewModel.fromJson(Map<String, dynamic> json) =
      _$ReviewModelImpl.fromJson;

  @override
  String get id;
  @override
  int get rating;
  @override
  String get comment;
  @override
  List<String> get images;
  @override
  DateTime get createdAt;
  @override
  ReviewUserModel? get user;
  @override
  String? get productId;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewModelImplCopyWith<_$ReviewModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewUserModel _$ReviewUserModelFromJson(Map<String, dynamic> json) {
  return _ReviewUserModel.fromJson(json);
}

/// @nodoc
mixin _$ReviewUserModel {
  String get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this ReviewUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewUserModelCopyWith<ReviewUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewUserModelCopyWith<$Res> {
  factory $ReviewUserModelCopyWith(
          ReviewUserModel value, $Res Function(ReviewUserModel) then) =
      _$ReviewUserModelCopyWithImpl<$Res, ReviewUserModel>;
  @useResult
  $Res call({String displayName, String? avatarUrl});
}

/// @nodoc
class _$ReviewUserModelCopyWithImpl<$Res, $Val extends ReviewUserModel>
    implements $ReviewUserModelCopyWith<$Res> {
  _$ReviewUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_value.copyWith(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewUserModelImplCopyWith<$Res>
    implements $ReviewUserModelCopyWith<$Res> {
  factory _$$ReviewUserModelImplCopyWith(_$ReviewUserModelImpl value,
          $Res Function(_$ReviewUserModelImpl) then) =
      __$$ReviewUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String displayName, String? avatarUrl});
}

/// @nodoc
class __$$ReviewUserModelImplCopyWithImpl<$Res>
    extends _$ReviewUserModelCopyWithImpl<$Res, _$ReviewUserModelImpl>
    implements _$$ReviewUserModelImplCopyWith<$Res> {
  __$$ReviewUserModelImplCopyWithImpl(
      _$ReviewUserModelImpl _value, $Res Function(_$ReviewUserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$ReviewUserModelImpl(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewUserModelImpl implements _ReviewUserModel {
  const _$ReviewUserModelImpl({required this.displayName, this.avatarUrl});

  factory _$ReviewUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewUserModelImplFromJson(json);

  @override
  final String displayName;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'ReviewUserModel(displayName: $displayName, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewUserModelImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, displayName, avatarUrl);

  /// Create a copy of ReviewUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewUserModelImplCopyWith<_$ReviewUserModelImpl> get copyWith =>
      __$$ReviewUserModelImplCopyWithImpl<_$ReviewUserModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewUserModelImplToJson(
      this,
    );
  }
}

abstract class _ReviewUserModel implements ReviewUserModel {
  const factory _ReviewUserModel(
      {required final String displayName,
      final String? avatarUrl}) = _$ReviewUserModelImpl;

  factory _ReviewUserModel.fromJson(Map<String, dynamic> json) =
      _$ReviewUserModelImpl.fromJson;

  @override
  String get displayName;
  @override
  String? get avatarUrl;

  /// Create a copy of ReviewUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewUserModelImplCopyWith<_$ReviewUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateReviewRequest _$CreateReviewRequestFromJson(Map<String, dynamic> json) {
  return _CreateReviewRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateReviewRequest {
  String get orderItemId => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;

  /// Serializes this CreateReviewRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateReviewRequestCopyWith<CreateReviewRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateReviewRequestCopyWith<$Res> {
  factory $CreateReviewRequestCopyWith(
          CreateReviewRequest value, $Res Function(CreateReviewRequest) then) =
      _$CreateReviewRequestCopyWithImpl<$Res, CreateReviewRequest>;
  @useResult
  $Res call(
      {String orderItemId, int rating, String comment, List<String> images});
}

/// @nodoc
class _$CreateReviewRequestCopyWithImpl<$Res, $Val extends CreateReviewRequest>
    implements $CreateReviewRequestCopyWith<$Res> {
  _$CreateReviewRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderItemId = null,
    Object? rating = null,
    Object? comment = null,
    Object? images = null,
  }) {
    return _then(_value.copyWith(
      orderItemId: null == orderItemId
          ? _value.orderItemId
          : orderItemId // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateReviewRequestImplCopyWith<$Res>
    implements $CreateReviewRequestCopyWith<$Res> {
  factory _$$CreateReviewRequestImplCopyWith(_$CreateReviewRequestImpl value,
          $Res Function(_$CreateReviewRequestImpl) then) =
      __$$CreateReviewRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String orderItemId, int rating, String comment, List<String> images});
}

/// @nodoc
class __$$CreateReviewRequestImplCopyWithImpl<$Res>
    extends _$CreateReviewRequestCopyWithImpl<$Res, _$CreateReviewRequestImpl>
    implements _$$CreateReviewRequestImplCopyWith<$Res> {
  __$$CreateReviewRequestImplCopyWithImpl(_$CreateReviewRequestImpl _value,
      $Res Function(_$CreateReviewRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderItemId = null,
    Object? rating = null,
    Object? comment = null,
    Object? images = null,
  }) {
    return _then(_$CreateReviewRequestImpl(
      orderItemId: null == orderItemId
          ? _value.orderItemId
          : orderItemId // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateReviewRequestImpl implements _CreateReviewRequest {
  const _$CreateReviewRequestImpl(
      {required this.orderItemId,
      required this.rating,
      required this.comment,
      final List<String> images = const []})
      : _images = images;

  factory _$CreateReviewRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateReviewRequestImplFromJson(json);

  @override
  final String orderItemId;
  @override
  final int rating;
  @override
  final String comment;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString() {
    return 'CreateReviewRequest(orderItemId: $orderItemId, rating: $rating, comment: $comment, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateReviewRequestImpl &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, orderItemId, rating, comment,
      const DeepCollectionEquality().hash(_images));

  /// Create a copy of CreateReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateReviewRequestImplCopyWith<_$CreateReviewRequestImpl> get copyWith =>
      __$$CreateReviewRequestImplCopyWithImpl<_$CreateReviewRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateReviewRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateReviewRequest implements CreateReviewRequest {
  const factory _CreateReviewRequest(
      {required final String orderItemId,
      required final int rating,
      required final String comment,
      final List<String> images}) = _$CreateReviewRequestImpl;

  factory _CreateReviewRequest.fromJson(Map<String, dynamic> json) =
      _$CreateReviewRequestImpl.fromJson;

  @override
  String get orderItemId;
  @override
  int get rating;
  @override
  String get comment;
  @override
  List<String> get images;

  /// Create a copy of CreateReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateReviewRequestImplCopyWith<_$CreateReviewRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
