import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

/// Persists wishlist products as JSON in SharedPreferences (local storage).
class WishlistRepository {
  static const String _key = 'wishlist_products';

  Future<List<Product>> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveWishlist(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(products
        .map((p) => {
              'id': p.id,
              'title': p.title,
              'description': p.description,
              'price': p.price,
              'rating': p.rating,
              'category': p.category,
              'thumbnail': p.thumbnail,
              'images': p.images,
            })
        .toList());
    await prefs.setString(_key, raw);
  }
}
