// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modifier_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModifierGroupModel _$ModifierGroupModelFromJson(Map<String, dynamic> json) {
  return _ModifierGroupModel.fromJson(json);
}

/// @nodoc
mixin _$ModifierGroupModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get selectionType => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  List<ModifierOptionModel> get options => throw _privateConstructorUsedError;

  /// Serializes this ModifierGroupModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModifierGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModifierGroupModelCopyWith<ModifierGroupModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModifierGroupModelCopyWith<$Res> {
  factory $ModifierGroupModelCopyWith(
          ModifierGroupModel value, $Res Function(ModifierGroupModel) then) =
      _$ModifierGroupModelCopyWithImpl<$Res, ModifierGroupModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String selectionType,
      bool isRequired,
      int sortOrder,
      List<ModifierOptionModel> options});
}

/// @nodoc
class _$ModifierGroupModelCopyWithImpl<$Res, $Val extends ModifierGroupModel>
    implements $ModifierGroupModelCopyWith<$Res> {
  _$ModifierGroupModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModifierGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? selectionType = null,
    Object? isRequired = null,
    Object? sortOrder = null,
    Object? options = null,
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
      selectionType: null == selectionType
          ? _value.selectionType
          : selectionType // ignore: cast_nullable_to_non_nullable
              as String,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<ModifierOptionModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModifierGroupModelImplCopyWith<$Res>
    implements $ModifierGroupModelCopyWith<$Res> {
  factory _$$ModifierGroupModelImplCopyWith(_$ModifierGroupModelImpl value,
          $Res Function(_$ModifierGroupModelImpl) then) =
      __$$ModifierGroupModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String selectionType,
      bool isRequired,
      int sortOrder,
      List<ModifierOptionModel> options});
}

/// @nodoc
class __$$ModifierGroupModelImplCopyWithImpl<$Res>
    extends _$ModifierGroupModelCopyWithImpl<$Res, _$ModifierGroupModelImpl>
    implements _$$ModifierGroupModelImplCopyWith<$Res> {
  __$$ModifierGroupModelImplCopyWithImpl(_$ModifierGroupModelImpl _value,
      $Res Function(_$ModifierGroupModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModifierGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? selectionType = null,
    Object? isRequired = null,
    Object? sortOrder = null,
    Object? options = null,
  }) {
    return _then(_$ModifierGroupModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      selectionType: null == selectionType
          ? _value.selectionType
          : selectionType // ignore: cast_nullable_to_non_nullable
              as String,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<ModifierOptionModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModifierGroupModelImpl extends _ModifierGroupModel {
  const _$ModifierGroupModelImpl(
      {required this.id,
      required this.name,
      this.selectionType = 'SINGLE',
      this.isRequired = false,
      this.sortOrder = 0,
      final List<ModifierOptionModel> options = const <ModifierOptionModel>[]})
      : _options = options,
        super._();

  factory _$ModifierGroupModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModifierGroupModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String selectionType;
  @override
  @JsonKey()
  final bool isRequired;
  @override
  @JsonKey()
  final int sortOrder;
  final List<ModifierOptionModel> _options;
  @override
  @JsonKey()
  List<ModifierOptionModel> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'ModifierGroupModel(id: $id, name: $name, selectionType: $selectionType, isRequired: $isRequired, sortOrder: $sortOrder, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModifierGroupModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.selectionType, selectionType) ||
                other.selectionType == selectionType) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, selectionType,
      isRequired, sortOrder, const DeepCollectionEquality().hash(_options));

  /// Create a copy of ModifierGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModifierGroupModelImplCopyWith<_$ModifierGroupModelImpl> get copyWith =>
      __$$ModifierGroupModelImplCopyWithImpl<_$ModifierGroupModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModifierGroupModelImplToJson(
      this,
    );
  }
}

abstract class _ModifierGroupModel extends ModifierGroupModel {
  const factory _ModifierGroupModel(
      {required final String id,
      required final String name,
      final String selectionType,
      final bool isRequired,
      final int sortOrder,
      final List<ModifierOptionModel> options}) = _$ModifierGroupModelImpl;
  const _ModifierGroupModel._() : super._();

  factory _ModifierGroupModel.fromJson(Map<String, dynamic> json) =
      _$ModifierGroupModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get selectionType;
  @override
  bool get isRequired;
  @override
  int get sortOrder;
  @override
  List<ModifierOptionModel> get options;

  /// Create a copy of ModifierGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModifierGroupModelImplCopyWith<_$ModifierGroupModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModifierOptionModel _$ModifierOptionModelFromJson(Map<String, dynamic> json) {
  return _ModifierOptionModel.fromJson(json);
}

/// @nodoc
mixin _$ModifierOptionModel {
  String get id => throw _privateConstructorUsedError;
  String get label =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: numToDouble)
  double get priceDelta => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this ModifierOptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModifierOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModifierOptionModelCopyWith<ModifierOptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModifierOptionModelCopyWith<$Res> {
  factory $ModifierOptionModelCopyWith(
          ModifierOptionModel value, $Res Function(ModifierOptionModel) then) =
      _$ModifierOptionModelCopyWithImpl<$Res, ModifierOptionModel>;
  @useResult
  $Res call(
      {String id,
      String label,
      @JsonKey(fromJson: numToDouble) double priceDelta,
      bool isDefault});
}

/// @nodoc
class _$ModifierOptionModelCopyWithImpl<$Res, $Val extends ModifierOptionModel>
    implements $ModifierOptionModelCopyWith<$Res> {
  _$ModifierOptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModifierOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? priceDelta = null,
    Object? isDefault = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      priceDelta: null == priceDelta
          ? _value.priceDelta
          : priceDelta // ignore: cast_nullable_to_non_nullable
              as double,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModifierOptionModelImplCopyWith<$Res>
    implements $ModifierOptionModelCopyWith<$Res> {
  factory _$$ModifierOptionModelImplCopyWith(_$ModifierOptionModelImpl value,
          $Res Function(_$ModifierOptionModelImpl) then) =
      __$$ModifierOptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      @JsonKey(fromJson: numToDouble) double priceDelta,
      bool isDefault});
}

/// @nodoc
class __$$ModifierOptionModelImplCopyWithImpl<$Res>
    extends _$ModifierOptionModelCopyWithImpl<$Res, _$ModifierOptionModelImpl>
    implements _$$ModifierOptionModelImplCopyWith<$Res> {
  __$$ModifierOptionModelImplCopyWithImpl(_$ModifierOptionModelImpl _value,
      $Res Function(_$ModifierOptionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModifierOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? priceDelta = null,
    Object? isDefault = null,
  }) {
    return _then(_$ModifierOptionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      priceDelta: null == priceDelta
          ? _value.priceDelta
          : priceDelta // ignore: cast_nullable_to_non_nullable
              as double,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModifierOptionModelImpl implements _ModifierOptionModel {
  const _$ModifierOptionModelImpl(
      {required this.id,
      required this.label,
      @JsonKey(fromJson: numToDouble) this.priceDelta = 0.0,
      this.isDefault = false});

  factory _$ModifierOptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModifierOptionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
// ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: numToDouble)
  final double priceDelta;
  @override
  @JsonKey()
  final bool isDefault;

  @override
  String toString() {
    return 'ModifierOptionModel(id: $id, label: $label, priceDelta: $priceDelta, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModifierOptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.priceDelta, priceDelta) ||
                other.priceDelta == priceDelta) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, priceDelta, isDefault);

  /// Create a copy of ModifierOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModifierOptionModelImplCopyWith<_$ModifierOptionModelImpl> get copyWith =>
      __$$ModifierOptionModelImplCopyWithImpl<_$ModifierOptionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModifierOptionModelImplToJson(
      this,
    );
  }
}

abstract class _ModifierOptionModel implements ModifierOptionModel {
  const factory _ModifierOptionModel(
      {required final String id,
      required final String label,
      @JsonKey(fromJson: numToDouble) final double priceDelta,
      final bool isDefault}) = _$ModifierOptionModelImpl;

  factory _ModifierOptionModel.fromJson(Map<String, dynamic> json) =
      _$ModifierOptionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get label; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: numToDouble)
  double get priceDelta;
  @override
  bool get isDefault;

  /// Create a copy of ModifierOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModifierOptionModelImplCopyWith<_$ModifierOptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SelectedModifierModel _$SelectedModifierModelFromJson(
    Map<String, dynamic> json) {
  return _SelectedModifierModel.fromJson(json);
}

/// @nodoc
mixin _$SelectedModifierModel {
  String get groupId => throw _privateConstructorUsedError;
  String get groupName => throw _privateConstructorUsedError;
  String get optionId => throw _privateConstructorUsedError;
  String get label =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: numToDouble)
  double get priceDelta => throw _privateConstructorUsedError;

  /// Serializes this SelectedModifierModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SelectedModifierModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectedModifierModelCopyWith<SelectedModifierModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedModifierModelCopyWith<$Res> {
  factory $SelectedModifierModelCopyWith(SelectedModifierModel value,
          $Res Function(SelectedModifierModel) then) =
      _$SelectedModifierModelCopyWithImpl<$Res, SelectedModifierModel>;
  @useResult
  $Res call(
      {String groupId,
      String groupName,
      String optionId,
      String label,
      @JsonKey(fromJson: numToDouble) double priceDelta});
}

/// @nodoc
class _$SelectedModifierModelCopyWithImpl<$Res,
        $Val extends SelectedModifierModel>
    implements $SelectedModifierModelCopyWith<$Res> {
  _$SelectedModifierModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectedModifierModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? groupName = null,
    Object? optionId = null,
    Object? label = null,
    Object? priceDelta = null,
  }) {
    return _then(_value.copyWith(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      optionId: null == optionId
          ? _value.optionId
          : optionId // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      priceDelta: null == priceDelta
          ? _value.priceDelta
          : priceDelta // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SelectedModifierModelImplCopyWith<$Res>
    implements $SelectedModifierModelCopyWith<$Res> {
  factory _$$SelectedModifierModelImplCopyWith(
          _$SelectedModifierModelImpl value,
          $Res Function(_$SelectedModifierModelImpl) then) =
      __$$SelectedModifierModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String groupId,
      String groupName,
      String optionId,
      String label,
      @JsonKey(fromJson: numToDouble) double priceDelta});
}

/// @nodoc
class __$$SelectedModifierModelImplCopyWithImpl<$Res>
    extends _$SelectedModifierModelCopyWithImpl<$Res,
        _$SelectedModifierModelImpl>
    implements _$$SelectedModifierModelImplCopyWith<$Res> {
  __$$SelectedModifierModelImplCopyWithImpl(_$SelectedModifierModelImpl _value,
      $Res Function(_$SelectedModifierModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SelectedModifierModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? groupName = null,
    Object? optionId = null,
    Object? label = null,
    Object? priceDelta = null,
  }) {
    return _then(_$SelectedModifierModelImpl(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      optionId: null == optionId
          ? _value.optionId
          : optionId // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      priceDelta: null == priceDelta
          ? _value.priceDelta
          : priceDelta // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SelectedModifierModelImpl implements _SelectedModifierModel {
  const _$SelectedModifierModelImpl(
      {required this.groupId,
      required this.groupName,
      required this.optionId,
      required this.label,
      @JsonKey(fromJson: numToDouble) this.priceDelta = 0.0});

  factory _$SelectedModifierModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelectedModifierModelImplFromJson(json);

  @override
  final String groupId;
  @override
  final String groupName;
  @override
  final String optionId;
  @override
  final String label;
// ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: numToDouble)
  final double priceDelta;

  @override
  String toString() {
    return 'SelectedModifierModel(groupId: $groupId, groupName: $groupName, optionId: $optionId, label: $label, priceDelta: $priceDelta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectedModifierModelImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.optionId, optionId) ||
                other.optionId == optionId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.priceDelta, priceDelta) ||
                other.priceDelta == priceDelta));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, groupId, groupName, optionId, label, priceDelta);

  /// Create a copy of SelectedModifierModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectedModifierModelImplCopyWith<_$SelectedModifierModelImpl>
      get copyWith => __$$SelectedModifierModelImplCopyWithImpl<
          _$SelectedModifierModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectedModifierModelImplToJson(
      this,
    );
  }
}

abstract class _SelectedModifierModel implements SelectedModifierModel {
  const factory _SelectedModifierModel(
          {required final String groupId,
          required final String groupName,
          required final String optionId,
          required final String label,
          @JsonKey(fromJson: numToDouble) final double priceDelta}) =
      _$SelectedModifierModelImpl;

  factory _SelectedModifierModel.fromJson(Map<String, dynamic> json) =
      _$SelectedModifierModelImpl.fromJson;

  @override
  String get groupId;
  @override
  String get groupName;
  @override
  String get optionId;
  @override
  String get label; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: numToDouble)
  double get priceDelta;

  /// Create a copy of SelectedModifierModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectedModifierModelImplCopyWith<_$SelectedModifierModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
