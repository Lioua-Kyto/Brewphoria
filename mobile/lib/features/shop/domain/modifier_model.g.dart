// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modifier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModifierGroupModelImpl _$$ModifierGroupModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ModifierGroupModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      selectionType: json['selectionType'] as String? ?? 'SINGLE',
      isRequired: json['isRequired'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) =>
                  ModifierOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ModifierOptionModel>[],
    );

Map<String, dynamic> _$$ModifierGroupModelImplToJson(
        _$ModifierGroupModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'selectionType': instance.selectionType,
      'isRequired': instance.isRequired,
      'sortOrder': instance.sortOrder,
      'options': instance.options,
    };

_$ModifierOptionModelImpl _$$ModifierOptionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ModifierOptionModelImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      priceDelta:
          json['priceDelta'] == null ? 0.0 : numToDouble(json['priceDelta']),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$ModifierOptionModelImplToJson(
        _$ModifierOptionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'priceDelta': instance.priceDelta,
      'isDefault': instance.isDefault,
    };

_$SelectedModifierModelImpl _$$SelectedModifierModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SelectedModifierModelImpl(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      optionId: json['optionId'] as String,
      label: json['label'] as String,
      priceDelta:
          json['priceDelta'] == null ? 0.0 : numToDouble(json['priceDelta']),
    );

Map<String, dynamic> _$$SelectedModifierModelImplToJson(
        _$SelectedModifierModelImpl instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'optionId': instance.optionId,
      'label': instance.label,
      'priceDelta': instance.priceDelta,
    };
