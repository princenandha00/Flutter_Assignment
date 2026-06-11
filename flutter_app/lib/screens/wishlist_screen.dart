import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wishlist_cubit.dart';
import '../bloc/wishlist_state.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(
              child: Text('Your wishlist is empty.\nTap the heart icon on a product to add it.',
                  textAlign: TextAlign.center),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) =>
                ProductCard(product: state.items[index]),
          );
        },
      ),
    );
  }
}
