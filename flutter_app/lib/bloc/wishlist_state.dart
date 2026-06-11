import 'package:equatable/equatable.dart';
import '../models/product.dart';

class WishlistState extends Equatable {
  final List<Product> items;
  final bool loaded;

  const WishlistState({this.items = const [], this.loaded = false});

  bool contains(int productId) => items.any((p) => p.id == productId);

  WishlistState copyWith({List<Product>? items, bool? loaded}) {
    return WishlistState(
      items: items ?? this.items,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props => [items, loaded];
}
