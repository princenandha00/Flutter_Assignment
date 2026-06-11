import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductRepository {
  static const String _baseUrl = 'https://dummyjson.com/products';

  /// Fetch a page of products.
  /// [limit] = page size, [skip] = offset for pagination.
  /// If [search] is provided, hits the /search endpoint.
  /// If [category] is provided, hits the /category/{category} endpoint.
  Future<ProductPage> fetchProducts({
    int limit = 20,
    int skip = 0,
    String? search,
    String? category,
  }) async {
    Uri uri;
    if (search != null && search.trim().isNotEmpty) {
      uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'q': search.trim(),
        'limit': '$limit',
        'skip': '$skip',
      });
    } else if (category != null && category.isNotEmpty && category != 'All') {
      uri = Uri.parse('$_baseUrl/category/$category').replace(
        queryParameters: {'limit': '$limit', 'skip': '$skip'},
      );
    } else {
      uri = Uri.parse(_baseUrl)
          .replace(queryParameters: {'limit': '$limit', 'skip': '$skip'});
    }

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load products (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductPage(
      products: products,
      total: data['total'] as int? ?? products.length,
      skip: data['skip'] as int? ?? skip,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetch list of all category slugs (used for filter chips).
  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$_baseUrl/categories');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load categories (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    // dummyjson returns list of {slug, name, url} objects
    return data
        .map((e) => (e is Map ? (e['slug'] ?? e['name']) : e).toString())
        .toList();
  }

  Future<Product> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load product (${response.statusCode})');
    }
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

class ProductPage {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + products.length < total;
}
