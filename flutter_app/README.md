# Product Catalog (Flutter + BLoC)

A Flutter app fulfilling **Part 1** of the assignment, using `flutter_bloc` for state management.

## API
https://dummyjson.com/products

## Features
- Fetches product list from the API (`ProductBloc` + `ProductRepository`)
- Displays products in a 2-column grid with image, title, and price
- Search by title (debounced 400ms, hits `/products/search?q=`)
- Filter by category (chips, fetched from `/products/categories`) and by price range (bottom sheet, applied client-side)
- Pagination via infinite scroll (`skip`/`limit`, loads more near bottom of list)
- Product detail screen with image gallery, description, price, and rating
- Pull-to-refresh
- **Wishlist** (bonus): tap the heart icon on any product card or detail screen to add/remove it from the wishlist; persisted locally via `shared_preferences`, accessible from the app bar heart icon

## Architecture
```
lib/
  models/product.dart            # Product data model
  bloc/
    product_event.dart
    product_state.dart
    product_bloc.dart            # Core BLoC: search/filter/pagination logic
    wishlist_state.dart
    wishlist_cubit.dart          # Wishlist cubit, persisted via shared_preferences
  repository/
    product_repository.dart
    wishlist_repository.dart     # Local storage (shared_preferences)
  screens/
    product_list_screen.dart
    product_detail_screen.dart
  widgets/
    product_card.dart
    price_filter_sheet.dart
  main.dart
```

## Setup
1. Install Flutter SDK (3.x).
2. `flutter pub get`
3. `flutter run`

## Bonus
- Wishlist (local storage) implemented via `shared_preferences` and `WishlistCubit`.
- Offline caching is left as a future enhancement; `ProductRepository` is structured so a local cache layer (e.g. `hive`/`sqflite`) can be added easily.
