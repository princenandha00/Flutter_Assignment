import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/price_filter_sheet.dart';
import 'wishlist_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductFetchStarted());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<ProductBloc>().add(const ProductLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Wishlist',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter by price',
            onPressed: () async {
              final state = context.read<ProductBloc>().state;
              final result = await showModalBottomSheet<(double?, double?)>(
                context: context,
                isScrollControlled: true,
                builder: (_) => PriceFilterSheet(
                  initialMin: state.minPrice,
                  initialMax: state.maxPrice,
                ),
              );
              if (result != null && context.mounted) {
                final (min, max) = result;
                context
                    .read<ProductBloc>()
                    .add(ProductPriceRangeChanged(minPrice: min, maxPrice: max));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<ProductBloc>()
                              .add(const ProductSearchChanged(''));
                          setState(() {});
                        },
                      ),
              ),
              onChanged: (value) {
                context.read<ProductBloc>().add(ProductSearchChanged(value));
                setState(() {});
              },
            ),
          ),
          BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (prev, curr) =>
                prev.categories != curr.categories ||
                prev.selectedCategory != curr.selectedCategory,
            builder: (context, state) {
              return SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final selected = category == state.selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        context
                            .read<ProductBloc>()
                            .add(ProductCategoryChanged(category));
                      },
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.status == ProductStatus.loading &&
                    state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ProductStatus.failure &&
                    state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error: ${state.errorMessage ?? "Unknown error"}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ProductBloc>()
                              .add(const ProductFetchStarted()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc>().add(const ProductRefreshed());
                    await context.read<ProductBloc>().stream.firstWhere(
                        (s) => s.status != ProductStatus.loading);
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: state.products.length +
                        (state.status == ProductStatus.loadingMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ProductCard(product: state.products[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
