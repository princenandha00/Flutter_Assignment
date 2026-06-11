import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/product_bloc.dart';
import 'bloc/wishlist_cubit.dart';
import 'repository/product_repository.dart';
import 'repository/wishlist_repository.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ProductRepository()),
        RepositoryProvider(create: (_) => WishlistRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ProductBloc(repository: context.read<ProductRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                WishlistCubit(repository: context.read<WishlistRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Product Catalog',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const ProductListScreen(),
        ),
      ),
    );
  }
}
