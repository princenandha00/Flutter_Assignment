import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../repository/wishlist_repository.dart';
import 'wishlist_state.dart';

/// Cubit (lightweight BLoC) managing the wishlist, persisted to local storage.
class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository repository;

  WishlistCubit({required this.repository}) : super(const WishlistState()) {
    _load();
  }

  Future<void> _load() async {
    final items = await repository.loadWishlist();
    emit(state.copyWith(items: items, loaded: true));
  }

  Future<void> toggle(Product product) async {
    final exists = state.contains(product.id);
    final updated = exists
        ? state.items.where((p) => p.id != product.id).toList()
        : [...state.items, product];
    emit(state.copyWith(items: updated));
    await repository.saveWishlist(updated);
  }

  Future<void> remove(int productId) async {
    final updated = state.items.where((p) => p.id != productId).toList();
    emit(state.copyWith(items: updated));
    await repository.saveWishlist(updated);
  }

  bool isWishlisted(int productId) => state.contains(productId);
}
