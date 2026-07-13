// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guestModeHash() => r'ac23393b7ee61f32c1a12858ee082facbe51173f';

/// Whether the user chose to browse without an account. Persisted so it
/// survives restarts. Cleared on sign-in / sign-out.
///
/// Copied from [GuestMode].
@ProviderFor(GuestMode)
final guestModeProvider = AutoDisposeNotifierProvider<GuestMode, bool>.internal(
  GuestMode.new,
  name: r'guestModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$guestModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GuestMode = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
