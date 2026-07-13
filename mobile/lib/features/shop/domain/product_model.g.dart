// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      stock: (json['stock'] as num).toInt(),
      isFeatured: json['isFeatured'] as bool? ?? false,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      type: json['type'] as String?,
      roastLevel: json['roastLevel'] as String?,
      calories: (json['calories'] as num?)?.toInt(),
      caffeineMg: (json['caffeineMg'] as num?)?.toInt(),
      prepMinutes: (json['prepMinutes'] as num?)?.toInt(),
      tastingNotes: (json['tastingNotes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      modifierGroups: (json['modifierGroups'] as List<dynamic>?)
              ?.map(
                  (e) => ModifierGroupModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ModifierGroupModel>[],
      category: _categoryFromJson(json['category'] as Map<String, dynamic>?),
      categoryId: json['categoryId'] as String?,
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'price': instance.price,
      'images': instance.images,
      'stock': instance.stock,
      'isFeatured': instance.isFeatured,
      'avgRating': instance.avgRating,
      'reviewCount': instance.reviewCount,
      'type': instance.type,
      'roastLevel': instance.roastLevel,
      'calories': instance.calories,
      'caffeineMg': instance.caffeineMg,
      'prepMinutes': instance.prepMinutes,
      'tastingNotes': instance.tastingNotes,
      'modifierGroups': instance.modifierGroups,
      'category': _categoryToJson(instance.category),
      'categoryId': instance.categoryId,
    };
