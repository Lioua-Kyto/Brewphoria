// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewDataSourceHash() => r'55c82fad7830cfc9930e992f1626abf14cfdcd1c';

/// See also [reviewDataSource].
@ProviderFor(reviewDataSource)
final reviewDataSourceProvider =
    AutoDisposeProvider<ReviewRemoteDatasource>.internal(
  reviewDataSource,
  name: r'reviewDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewDataSourceRef = AutoDisposeProviderRef<ReviewRemoteDatasource>;
String _$reviewNotifierHash() => r'b12671637eaab6e798c36c38e4a742eec4ba0a12';

/// See also [ReviewNotifier].
@ProviderFor(ReviewNotifier)
final reviewNotifierProvider = AutoDisposeNotifierProvider<ReviewNotifier,
    AsyncValue<ReviewModel?>>.internal(
  ReviewNotifier.new,
  name: r'reviewNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReviewNotifier = AutoDisposeNotifier<AsyncValue<ReviewModel?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
