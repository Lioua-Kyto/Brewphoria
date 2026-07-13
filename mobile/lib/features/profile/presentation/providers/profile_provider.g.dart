// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileDataSourceHash() => r'4a9e5fbedd8fa3e85087f2b8b0df5725502270c3';

/// See also [profileDataSource].
@ProviderFor(profileDataSource)
final profileDataSourceProvider =
    AutoDisposeProvider<ProfileRemoteDatasource>.internal(
  profileDataSource,
  name: r'profileDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileDataSourceRef = AutoDisposeProviderRef<ProfileRemoteDatasource>;
String _$userProfileHash() => r'd07763d0d0c2eeddf44ac86bb651f03a5ebdcb91';

/// See also [userProfile].
@ProviderFor(userProfile)
final userProfileProvider = AutoDisposeFutureProvider<UserModel>.internal(
  userProfile,
  name: r'userProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRef = AutoDisposeFutureProviderRef<UserModel>;
String _$userAddressesHash() => r'8d4d27690d4d636eb25267781a8ed12c66ffdde4';

/// See also [userAddresses].
@ProviderFor(userAddresses)
final userAddressesProvider =
    AutoDisposeFutureProvider<List<AddressModel>>.internal(
  userAddresses,
  name: r'userAddressesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userAddressesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserAddressesRef = AutoDisposeFutureProviderRef<List<AddressModel>>;
String _$addressesNotifierHash() => r'1555bb1e6cf063efcfb0ba3a75c8f2bc92c54eaa';

/// See also [AddressesNotifier].
@ProviderFor(AddressesNotifier)
final addressesNotifierProvider = AutoDisposeNotifierProvider<AddressesNotifier,
    AsyncValue<List<AddressModel>>>.internal(
  AddressesNotifier.new,
  name: r'addressesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addressesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AddressesNotifier
    = AutoDisposeNotifier<AsyncValue<List<AddressModel>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
