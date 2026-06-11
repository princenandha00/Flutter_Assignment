// prodect Model

class Product {
  final int id;
  final String title;
  final double price;

  Product({
    required this.id,
    required this.title,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price']).toDouble(),
    );
  }
}

// Fetch Api

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Product>> fetchProducts() async {
  final response = await http.get(
    Uri.parse('https://dummyjson.com/products'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return (data['products'] as List)
        .map((e) => Product.fromJson(e))
        .toList();
  } else {
    throw Exception('Failed to load products');
  }
}

// Display list
FutureBuilder<List<Product>>(
  future: fetchProducts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Text(snapshot.error.toString()),
      );
    }

    final products = snapshot.data!;

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(products[index].title),
          subtitle: Text(
            '\$${products[index].price}',
          ),
        );
      },
    );
  },
)

