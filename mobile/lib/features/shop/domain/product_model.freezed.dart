// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  double get avgRating => throw _privateConstructorUsedError;
  int get reviewCount =>
      throw _privateConstructorUsedError; // 'DRINK' | 'BEANS' | 'MERCH' — informational; the UI stays data-driven
// off modifierGroups/roastLevel/tastingNotes rather than branching on this.
  String? get type =>
      throw _privateConstructorUsedError; // Optional detail metadata (rendered when the backend provides it).
  String? get roastLevel => throw _privateConstructorUsedError;
  int? get calories => throw _privateConstructorUsedError;
  int? get caffeineMg => throw _privateConstructorUsedError;
  int? get prepMinutes => throw _privateConstructorUsedError;
  List<String> get tastingNotes => throw _privateConstructorUsedError;
  List<ModifierGroupModel> get modifierGroups =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
  CategoryModel? get category => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
          ProductModel value, $Res Function(ProductModel) then) =
      _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String slug,
      String description,
      double price,
      List<String> images,
      int stock,
      bool isFeatured,
      double avgRating,
      int reviewCount,
      String? type,
      String? roastLevel,
      int? calories,
      int? caffeineMg,
      int? prepMinutes,
      List<String> tastingNotes,
      List<ModifierGroupModel> modifierGroups,
      @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
      CategoryModel? category,
      String? categoryId});

  $CategoryModelCopyWith<$Res>? get category;
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = null,
    Object? price = null,
    Object? images = null,
    Object? stock = null,
    Object? isFeatured = null,
    Object? avgRating = null,
    Object? reviewCount = null,
    Object? type = freezed,
    Object? roastLevel = freezed,
    Object? calories = freezed,
    Object? caffeineMg = freezed,
    Object? prepMinutes = freezed,
    Object? tastingNotes = null,
    Object? modifierGroups = null,
    Object? category = freezed,
    Object? categoryId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      roastLevel: freezed == roastLevel
          ? _value.roastLevel
          : roastLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      caffeineMg: freezed == caffeineMg
          ? _value.caffeineMg
          : caffeineMg // ignore: cast_nullable_to_non_nullable
              as int?,
      prepMinutes: freezed == prepMinutes
          ? _value.prepMinutes
          : prepMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      tastingNotes: null == tastingNotes
          ? _value.tastingNotes
          : tastingNotes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      modifierGroups: null == modifierGroups
          ? _value.modifierGroups
          : modifierGroups // ignore: cast_nullable_to_non_nullable
              as List<ModifierGroupModel>,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryModelCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryModelCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
          _$ProductModelImpl value, $Res Function(_$ProductModelImpl) then) =
      __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String slug,
      String description,
      double price,
      List<String> images,
      int stock,
      bool isFeatured,
      double avgRating,
      int reviewCount,
      String? type,
      String? roastLevel,
      int? calories,
      int? caffeineMg,
      int? prepMinutes,
      List<String> tastingNotes,
      List<ModifierGroupModel> modifierGroups,
      @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
      CategoryModel? category,
      String? categoryId});

  @override
  $CategoryModelCopyWith<$Res>? get category;
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
      _$ProductModelImpl _value, $Res Function(_$ProductModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = null,
    Object? price = null,
    Object? images = null,
    Object? stock = null,
    Object? isFeatured = null,
    Object? avgRating = null,
    Object? reviewCount = null,
    Object? type = freezed,
    Object? roastLevel = freezed,
    Object? calories = freezed,
    Object? caffeineMg = freezed,
    Object? prepMinutes = freezed,
    Object? tastingNotes = null,
    Object? modifierGroups = null,
    Object? category = freezed,
    Object? categoryId = freezed,
  }) {
    return _then(_$ProductModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      roastLevel: freezed == roastLevel
          ? _value.roastLevel
          : roastLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      caffeineMg: freezed == caffeineMg
          ? _value.caffeineMg
          : caffeineMg // ignore: cast_nullable_to_non_nullable
              as int?,
      prepMinutes: freezed == prepMinutes
          ? _value.prepMinutes
          : prepMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      tastingNotes: null == tastingNotes
          ? _value._tastingNotes
          : tastingNotes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      modifierGroups: null == modifierGroups
          ? _value._modifierGroups
          : modifierGroups // ignore: cast_nullable_to_non_nullable
              as List<ModifierGroupModel>,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductModelImpl implements _ProductModel {
  const _$ProductModelImpl(
      {required this.id,
      required this.name,
      required this.slug,
      required this.description,
      required this.price,
      required final List<String> images,
      required this.stock,
      this.isFeatured = false,
      this.avgRating = 0.0,
      this.reviewCount = 0,
      this.type,
      this.roastLevel,
      this.calories,
      this.caffeineMg,
      this.prepMinutes,
      final List<String> tastingNotes = const <String>[],
      final List<ModifierGroupModel> modifierGroups =
          const <ModifierGroupModel>[],
      @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
      this.category,
      this.categoryId})
      : _images = images,
        _tastingNotes = tastingNotes,
        _modifierGroups = modifierGroups;

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String description;
  @override
  final double price;
  final List<String> _images;
  @override
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final int stock;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final double avgRating;
  @override
  @JsonKey()
  final int reviewCount;
// 'DRINK' | 'BEANS' | 'MERCH' — informational; the UI stays data-driven
// off modifierGroups/roastLevel/tastingNotes rather than branching on this.
  @override
  final String? type;
// Optional detail metadata (rendered when the backend provides it).
  @override
  final String? roastLevel;
  @override
  final int? calories;
  @override
  final int? caffeineMg;
  @override
  final int? prepMinutes;
  final List<String> _tastingNotes;
  @override
  @JsonKey()
  List<String> get tastingNotes {
    if (_tastingNotes is EqualUnmodifiableListView) return _tastingNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tastingNotes);
  }

  final List<ModifierGroupModel> _modifierGroups;
  @override
  @JsonKey()
  List<ModifierGroupModel> get modifierGroups {
    if (_modifierGroups is EqualUnmodifiableListView) return _modifierGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modifierGroups);
  }

// ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
  final CategoryModel? category;
  @override
  final String? categoryId;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, slug: $slug, description: $description, price: $price, images: $images, stock: $stock, isFeatured: $isFeatured, avgRating: $avgRating, reviewCount: $reviewCount, type: $type, roastLevel: $roastLevel, calories: $calories, caffeineMg: $caffeineMg, prepMinutes: $prepMinutes, tastingNotes: $tastingNotes, modifierGroups: $modifierGroups, category: $category, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.roastLevel, roastLevel) ||
                other.roastLevel == roastLevel) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.caffeineMg, caffeineMg) ||
                other.caffeineMg == caffeineMg) &&
            (identical(other.prepMinutes, prepMinutes) ||
                other.prepMinutes == prepMinutes) &&
            const DeepCollectionEquality()
                .equals(other._tastingNotes, _tastingNotes) &&
            const DeepCollectionEquality()
                .equals(other._modifierGroups, _modifierGroups) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        slug,
        description,
        price,
        const DeepCollectionEquality().hash(_images),
        stock,
        isFeatured,
        avgRating,
        reviewCount,
        type,
        roastLevel,
        calories,
        caffeineMg,
        prepMinutes,
        const DeepCollectionEquality().hash(_tastingNotes),
        const DeepCollectionEquality().hash(_modifierGroups),
        category,
        categoryId
      ]);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(
      this,
    );
  }
}

abstract class _ProductModel implements ProductModel {
  const factory _ProductModel(
      {required final String id,
      required final String name,
      required final String slug,
      required final String description,
      required final double price,
      required final List<String> images,
      required final int stock,
      final bool isFeatured,
      final double avgRating,
      final int reviewCount,
      final String? type,
      final String? roastLevel,
      final int? calories,
      final int? caffeineMg,
      final int? prepMinutes,
      final List<String> tastingNotes,
      final List<ModifierGroupModel> modifierGroups,
      @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
      final CategoryModel? category,
      final String? categoryId}) = _$ProductModelImpl;

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  String get description;
  @override
  double get price;
  @override
  List<String> get images;
  @override
  int get stock;
  @override
  bool get isFeatured;
  @override
  double get avgRating;
  @override
  int get reviewCount; // 'DRINK' | 'BEANS' | 'MERCH' — informational; the UI stays data-driven
// off modifierGroups/roastLevel/tastingNotes rather than branching on this.
  @override
  String?
      get type; // Optional detail metadata (rendered when the backend provides it).
  @override
  String? get roastLevel;
  @override
  int? get calories;
  @override
  int? get caffeineMg;
  @override
  int? get prepMinutes;
  @override
  List<String> get tastingNotes;
  @override
  List<ModifierGroupModel>
      get modifierGroups; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
  CategoryModel? get category;
  @override
  String? get categoryId;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
