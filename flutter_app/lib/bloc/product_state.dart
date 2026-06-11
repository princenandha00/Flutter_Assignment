import 'package:equatable/equatable.dart';
import '../models/product.dart';

enum ProductStatus { initial, loading, success, failure, loadingMore }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final bool hasReachedMax;
  final String searchQuery;
  final String selectedCategory;
  final List<String> categories;
  final double? minPrice;
  final double? maxPrice;
  final String? errorMessage;
  final int skip;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.categories = const ['All'],
    this.minPrice,
    this.maxPrice,
    this.errorMessage,
    this.skip = 0,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    String? selectedCategory,
    List<String>? categories,
    double? minPrice,
    double? maxPrice,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    String? errorMessage,
    int? skip,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      errorMessage: errorMessage,
      skip: skip ?? this.skip,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        hasReachedMax,
        searchQuery,
        selectedCategory,
        categories,
        minPrice,
        maxPrice,
        errorMessage,
        skip,
      ];
}
