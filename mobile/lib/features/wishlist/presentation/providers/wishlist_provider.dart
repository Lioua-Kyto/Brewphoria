import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';
import 'package:brewphoria/features/wishlist/data/wishlist_remote_datasource.dart';

part 'wishlist_provider.g.dart';

@riverpod
class WishlistNotifier extends _$WishlistNotifier {
  final _ds = WishlistRemoteDatasource();

  @override
  Future<List<ProductModel>> build() async {
    return _ds.getWishlist();
  }

  Future<void> toggle(String productId) async {
    final current = state.valueOrNull ?? const <ProductModel>[];
    final isSaved = current.any((p) => p.id == productId);
    final previous = state;
    try {
      final list =
          isSaved ? await _ds.remove(productId) : await _ds.add(productId);
      state = AsyncValue.data(list);
    } catch (e) {
      state = previous;
      rethrow;
    }
  }
}

@riverpod
Set<String> wishlistIds(Ref ref) {
  final list = ref.watch(wishlistNotifierProvider).valueOrNull ?? const [];
  return list.map((p) => p.id).toSet();
}
