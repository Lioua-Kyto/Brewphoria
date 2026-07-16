import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brewphoria/features/profile/data/profile_remote_datasource.dart';
import 'package:brewphoria/features/profile/domain/profile_model.dart';
import 'package:brewphoria/features/auth/domain/user_model.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileRemoteDatasource profileDataSource(Ref ref) => ProfileRemoteDatasource();

@riverpod
Future<UserModel> userProfile(Ref ref) async {
  return ref.read(profileDataSourceProvider).getProfile();
}

@riverpod
Future<List<AddressModel>> userAddresses(Ref ref) async {
  return ref.read(profileDataSourceProvider).getAddresses();
}

@riverpod
class AddressesNotifier extends _$AddressesNotifier {
  @override
  AsyncValue<List<AddressModel>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(profileDataSourceProvider).getAddresses(),
    );
  }

  Future<void> addAddress(Map<String, dynamic> data) async {
    await ref.read(profileDataSourceProvider).addAddress(data);
    await _load();
  }

  Future<void> updateAddress(String id, Map<String, dynamic> data) async {
    await ref.read(profileDataSourceProvider).updateAddress(id, data);
    await _load();
  }

  Future<void> deleteAddress(String id) async {
    await ref.read(profileDataSourceProvider).deleteAddress(id);
    state = AsyncValue.data(
      state.valueOrNull?.where((a) => a.id != id).toList() ?? [],
    );
  }

  Future<void> refresh() => _load();
}
