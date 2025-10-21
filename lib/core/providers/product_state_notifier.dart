import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/sync_products.dart';
import 'providers.dart';

/// Estado de productos
class ProductState {
  final List<Product> products;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final String? successMessage;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.successMessage,
  });

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Notificador de estado de productos
class ProductStateNotifier extends StateNotifier<ProductState> {
  final GetAllProducts _getAllProducts;
  final SearchProducts _searchProducts;
  final SyncProducts _syncProducts;

  ProductStateNotifier(
    this._getAllProducts,
    this._searchProducts,
    this._syncProducts,
  ) : super(const ProductState());

  /// Cargar todos los productos
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final products = await _getAllProducts();
      state = state.copyWith(
        products: products,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Buscar productos
  Future<void> searchProducts(String query) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final products = await _searchProducts(query);
      state = state.copyWith(
        products: products,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Sincronizar productos desde la API
  Future<void> syncProducts() async {
    state = state.copyWith(isSyncing: true, clearError: true, clearSuccess: true);

    try {
      final products = await _syncProducts();
      state = state.copyWith(
        products: products,
        isSyncing: false,
        successMessage: '${products.length} productos sincronizados exitosamente',
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Error al sincronizar productos: ${e.toString().replaceAll('Exception: ', '')}',
      );
      rethrow;
    }
  }

  /// Limpiar mensajes
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

/// Provider del notificador de productos
final productStateProvider =
    StateNotifierProvider<ProductStateNotifier, ProductState>((ref) {
  final getAllProducts = ref.watch(getAllProductsProvider);
  final searchProducts = ref.watch(searchProductsProvider);
  final syncProducts = ref.watch(syncProductsProvider);
  return ProductStateNotifier(getAllProducts, searchProducts, syncProducts);
});

