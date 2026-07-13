// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatDataSourceHash() => r'03e8ed486cb6831793b1a4bbee499ed187290f53';

/// See also [chatDataSource].
@ProviderFor(chatDataSource)
final chatDataSourceProvider =
    AutoDisposeProvider<ChatRemoteDatasource>.internal(
  chatDataSource,
  name: r'chatDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatDataSourceRef = AutoDisposeProviderRef<ChatRemoteDatasource>;
String _$chatNotifierHash() => r'351652f1dec497923aa4de3d5f8cec9556b8eb5c';

/// See also [ChatNotifier].
@ProviderFor(ChatNotifier)
final chatNotifierProvider =
    AutoDisposeNotifierProvider<ChatNotifier, List<ChatMessageModel>>.internal(
  ChatNotifier.new,
  name: r'chatNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatNotifier = AutoDisposeNotifier<List<ChatMessageModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
