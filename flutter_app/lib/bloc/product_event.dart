import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductFetchStarted extends ProductEvent {
  const ProductFetchStarted();
}


class ProductLoadMoreRequested extends ProductEvent {
  const ProductLoadMoreRequested();
}


class ProductSearchChanged extends ProductEvent {
  final String query;
  const ProductSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}


class ProductCategoryChanged extends ProductEvent {
  final String category; 
  const ProductCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}


class ProductPriceRangeChanged extends ProductEvent {
  final double? minPrice;
  final double? maxPrice;
  const ProductPriceRangeChanged({this.minPrice, this.maxPrice});

  @override
  List<Object?> get props => [minPrice, maxPrice];
}


class ProductRefreshed extends ProductEvent {
  const ProductRefreshed();
}
