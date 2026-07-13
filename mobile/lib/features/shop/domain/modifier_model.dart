import 'package:freezed_annotation/freezed_annotation.dart';

part 'modifier_model.freezed.dart';
part 'modifier_model.g.dart';

/// Tolerant number parse — the API serializes some money fields as strings
/// (Prisma `Decimal`), others as numbers.
double numToDouble(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

/// A customization group offered for a product's category (Size, Milk,
/// Sweetness, Add-ons). `SINGLE` groups pick one option; `MULTI` allow many.
@freezed
class ModifierGroupModel with _$ModifierGroupModel {
  const factory ModifierGroupModel({
    required String id,
    required String name,
    @Default('SINGLE') String selectionType,
    @Default(false) bool isRequired,
    @Default(0) int sortOrder,
    @Default(<ModifierOptionModel>[]) List<ModifierOptionModel> options,
  }) = _ModifierGroupModel;

  const ModifierGroupModel._();

  bool get isMulti => selectionType == 'MULTI';

  factory ModifierGroupModel.fromJson(Map<String, dynamic> json) =>
      _$ModifierGroupModelFromJson(json);
}

@freezed
class ModifierOptionModel with _$ModifierOptionModel {
  const factory ModifierOptionModel({
    required String id,
    required String label,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: numToDouble) @Default(0.0) double priceDelta,
    @Default(false) bool isDefault,
  }) = _ModifierOptionModel;

  factory ModifierOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ModifierOptionModelFromJson(json);
}

/// A selected-modifier snapshot as stored on a cart / order line.
@freezed
class SelectedModifierModel with _$SelectedModifierModel {
  const factory SelectedModifierModel({
    required String groupId,
    required String groupName,
    required String optionId,
    required String label,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: numToDouble) @Default(0.0) double priceDelta,
  }) = _SelectedModifierModel;

  factory SelectedModifierModel.fromJson(Map<String, dynamic> json) =>
      _$SelectedModifierModelFromJson(json);
}
