import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered on initial screen load.
class ProductFetchStarted extends ProductEvent {
  const ProductFetchStarted();
}

/// Triggered when user scrolls near the bottom (infinite scroll / "load more").
class ProductLoadMoreRequested extends ProductEvent {
  const ProductLoadMoreRequested();
}

/// Triggered when user types in the search box. Debounced in the UI layer.
class ProductSearchChanged extends ProductEvent {
  final String query;
  const ProductSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Triggered when user selects a category filter.
class ProductCategoryChanged extends ProductEvent {
  final String category; // "All" means no filter
  const ProductCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

/// Triggered when user applies a price range filter.
class ProductPriceRangeChanged extends ProductEvent {
  final double? minPrice;
  final double? maxPrice;
  const ProductPriceRangeChanged({this.minPrice, this.maxPrice});

  @override
  List<Object?> get props => [minPrice, maxPrice];
}

/// Pull-to-refresh.
class ProductRefreshed extends ProductEvent {
  const ProductRefreshed();
}
