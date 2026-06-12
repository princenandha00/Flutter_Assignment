import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/product.dart';
import '../repository/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

const _pageLimit = 20;
const _searchDebounceDuration = Duration(milliseconds: 400);


EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

 
  List<Product> _allLoaded = [];

  ProductBloc({required this.repository}) : super(const ProductState()) {
    on<ProductFetchStarted>(_onFetchStarted);
    on<ProductLoadMoreRequested>(_onLoadMoreRequested);
    on<ProductRefreshed>(_onRefreshed);
    on<ProductCategoryChanged>(_onCategoryChanged);
    on<ProductPriceRangeChanged>(_onPriceRangeChanged);

   
    on<ProductSearchChanged>(
      _onSearchChanged,
      transformer: _debounce(_searchDebounceDuration),
    );
  }

  Future<void> _onFetchStarted(
    ProductFetchStarted event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading, errorMessage: null));
    try {
      final categories = await repository.fetchCategories();
      final page = await repository.fetchProducts(limit: _pageLimit, skip: 0);
      _allLoaded = page.products;
      emit(state.copyWith(
        status: ProductStatus.success,
        products: _applyPriceFilter(_allLoaded),
        hasReachedMax: !page.hasMore,
        skip: page.products.length,
        categories: ['All', ...categories],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshed(
    ProductRefreshed event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final page = await repository.fetchProducts(
        limit: _pageLimit,
        skip: 0,
        search: state.searchQuery,
        category: state.selectedCategory,
      );
      _allLoaded = page.products;
      emit(state.copyWith(
        status: ProductStatus.success,
        products: _applyPriceFilter(_allLoaded),
        hasReachedMax: !page.hasMore,
        skip: page.products.length,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreRequested(
    ProductLoadMoreRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state.hasReachedMax || state.status == ProductStatus.loadingMore) {
      return;
    }
    emit(state.copyWith(status: ProductStatus.loadingMore));
    try {
      final page = await repository.fetchProducts(
        limit: _pageLimit,
        skip: state.skip,
        search: state.searchQuery,
        category: state.selectedCategory,
      );
      _allLoaded = [..._allLoaded, ...page.products];
      emit(state.copyWith(
        status: ProductStatus.success,
        products: _applyPriceFilter(_allLoaded),
        hasReachedMax: !page.hasMore,
        skip: state.skip + page.products.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      searchQuery: event.query,
    ));
    try {
      final page = await repository.fetchProducts(
        limit: _pageLimit,
        skip: 0,
        search: event.query,
        category: state.selectedCategory,
      );
      _allLoaded = page.products;
      emit(state.copyWith(
        status: ProductStatus.success,
        products: _applyPriceFilter(_allLoaded),
        hasReachedMax: !page.hasMore,
        skip: page.products.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCategoryChanged(
    ProductCategoryChanged event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      selectedCategory: event.category,
    ));
    try {
      final page = await repository.fetchProducts(
        limit: _pageLimit,
        skip: 0,
        search: state.searchQuery,
        category: event.category,
      );
      _allLoaded = page.products;
      emit(state.copyWith(
        status: ProductStatus.success,
        products: _applyPriceFilter(_allLoaded),
        hasReachedMax: !page.hasMore,
        skip: page.products.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onPriceRangeChanged(
    ProductPriceRangeChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      clearMinPrice: event.minPrice == null,
      clearMaxPrice: event.maxPrice == null,
      products: _applyPriceFilter(
        _allLoaded,
        min: event.minPrice,
        max: event.maxPrice,
      ),
    ));
  }

  List<Product> _applyPriceFilter(
    List<Product> source, {
    double? min,
    double? max,
  }) {
    final lo = min ?? state.minPrice;
    final hi = max ?? state.maxPrice;
    if (lo == null && hi == null) return source;
    return source.where((p) {
      if (lo != null && p.price < lo) return false;
      if (hi != null && p.price > hi) return false;
      return true;
    }).toList();
  }
}
