// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationDataSourceHash() =>
    r'cc11b44e96deccef84329345ca2081318eaddc01';

/// See also [notificationDataSource].
@ProviderFor(notificationDataSource)
final notificationDataSourceProvider =
    AutoDisposeProvider<NotificationRemoteDatasource>.internal(
  notificationDataSource,
  name: r'notificationDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationDataSourceRef
    = AutoDisposeProviderRef<NotificationRemoteDatasource>;
String _$notificationsNotifierHash() =>
    r'5a072f8e0addd250a08c968f1f3ef33efb1e9f81';

/// See also [NotificationsNotifier].
@ProviderFor(NotificationsNotifier)
final notificationsNotifierProvider = AutoDisposeNotifierProvider<
    NotificationsNotifier, AsyncValue<List<NotificationModel>>>.internal(
  NotificationsNotifier.new,
  name: r'notificationsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationsNotifier
    = AutoDisposeNotifier<AsyncValue<List<NotificationModel>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
