import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:brewphoria/features/shop/domain/category_model.dart';
import 'package:brewphoria/features/shop/domain/modifier_model.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String slug,
    required String description,
    required double price,
    required List<String> images,
    required int stock,
    @Default(false) bool isFeatured,
    @Default(0.0) double avgRating,
    @Default(0) int reviewCount,
    // 'DRINK' | 'BEANS' | 'MERCH' — informational; the UI stays data-driven
    // off modifierGroups/roastLevel/tastingNotes rather than branching on this.
    String? type,
    // Optional detail metadata (rendered when the backend provides it).
    String? roastLevel,
    int? calories,
    int? caffeineMg,
    int? prepMinutes,
    @Default(<String>[]) List<String> tastingNotes,
    @Default(<ModifierGroupModel>[]) List<ModifierGroupModel> modifierGroups,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
    CategoryModel? category,
    String? categoryId,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}

CategoryModel? _categoryFromJson(Map<String, dynamic>? json) =>
    json == null ? null : CategoryModel.fromJson(json);

Map<String, dynamic>? _categoryToJson(CategoryModel? model) => model?.toJson();
