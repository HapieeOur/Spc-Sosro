import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/models/product.dart';
import 'package:spc_sosro/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final activeProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchActiveProducts();
});

final allProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchAllProducts();
});

final productSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredActiveProductsProvider = Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(activeProductsProvider);
  final query = ref.watch(productSearchQueryProvider).toLowerCase().trim();

  return productsAsync.whenData((products) {
    if (query.isEmpty) return products;
    return products.where((p) {
      return p.code.toLowerCase().contains(query) ||
          p.name.toLowerCase().contains(query);
    }).toList();
  });
});
