import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/injection/injection_container.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/get_all_products.dart';
import '../../../domain/usecases/get_current_user.dart';
import '../../../domain/usecases/logout_user.dart';
import '../../../domain/usecases/search_products.dart';
import '../../../domain/usecases/sync_products.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/product_card.dart';
import '../auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final InjectionContainer _container = InjectionContainer();
  late final GetAllProducts _getAllProducts;
  late final SearchProducts _searchProducts;
  late final SyncProducts _syncProducts;
  late final GetCurrentUser _getCurrentUser;
  late final LogoutUser _logoutUser;

  List<Product> _products = [];
  User? _currentUser;
  bool _isLoading = true;
  bool _isSyncing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAllProducts = _container.getAllProducts;
    _searchProducts = _container.searchProducts;
    _syncProducts = _container.syncProducts;
    _getCurrentUser = _container.getCurrentUser;
    _logoutUser = _container.logoutUser;
    _loadUserAndProducts();
  }

  Future<void> _loadUserAndProducts() async {
    // Load user first
    _currentUser = await _getCurrentUser();
    // Then load products
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final products = await _getAllProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Error al cargar productos: $e');
      }
    }
  }

  Future<void> _searchProductsHandler(String searchTerm) async {
    if (searchTerm.isEmpty) {
      _loadProducts();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final products = await _searchProducts(searchTerm);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Error al buscar productos: $e');
      }
    }
  }

  Future<void> _syncProductsFromApi() async {
    setState(() => _isSyncing = true);

    try {
      final products = await _syncProducts();
      setState(() {
        _products = products;
        _isSyncing = false;
        _searchController.clear();
      });

      if (mounted) {
        _showSuccessSnackBar(
            '${products.length} productos sincronizados exitosamente');
      }
    } catch (e) {
      setState(() => _isSyncing = false);
      if (mounted) {
        _showErrorSnackBar('Error al sincronizar productos: $e');
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          '¿Está seguro que desea cerrar sesión?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logoutUser();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Header con búsqueda y estadísticas
          _buildHeader(),

          // Syncing indicator
          if (_isSyncing)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingSmall,
              ),
              child: const LinearProgressIndicator(
                color: AppTheme.primaryColor,
                backgroundColor: AppTheme.borderColor,
              ),
            ),

          // Products Grid
          Expanded(child: _buildProductsGrid()),
        ],
      ),
      floatingActionButton: _isSyncing
          ? null
          : FloatingActionButton.extended(
              onPressed: _syncProductsFromApi,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar'),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppTheme.borderColor,
          height: 1,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(Icons.restaurant_menu,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Restobar POS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (_currentUser != null)
                Text(
                  _currentUser!.firstName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        // Sync button
        IconButton(
          icon: const Icon(Icons.cloud_sync, color: AppTheme.primaryColor),
          onPressed: _isSyncing ? null : _syncProductsFromApi,
          tooltip: 'Sincronizar desde API',
        ),

        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
          onPressed: _isLoading
              ? null
              : () {
                  _searchController.clear();
                  _loadProducts();
                },
          tooltip: 'Recargar productos',
        ),

        // User menu
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              _currentUser?.firstName.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          color: AppTheme.surfaceColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          tooltip: 'Menú de usuario',
          itemBuilder: (context) => [
            if (_currentUser != null)
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser!.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${_currentUser!.username}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentUser!.companyCode,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: AppTheme.errorColor),
                  SizedBox(width: AppTheme.spacingSmall),
                  Text('Cerrar Sesión',
                      style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              _handleLogout();
            }
          },
        ),
        const SizedBox(width: AppTheme.spacingSmall),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory_2,
                  label: 'Productos',
                  value: '${_products.length}',
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Activos',
                  value: '${_products.where((p) => p.isActive).length}',
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.cancel,
                  label: 'Inactivos',
                  value: '${_products.where((p) => !p.isActive).length}',
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Barra de búsqueda
          TextField(
            controller: _searchController,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
            cursorColor: AppTheme.primaryColor,
            decoration: InputDecoration(
              hintText: 'Buscar productos por nombre o código...',
              hintStyle: const TextStyle(color: AppTheme.textDisabled),
              prefixIcon: const Icon(Icons.search,
                  color: AppTheme.primaryColor, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          color: AppTheme.textSecondary, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _loadProducts();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surfaceColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingMedium,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide:
                    const BorderSide(color: AppTheme.borderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide:
                    const BorderSide(color: AppTheme.borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide:
                    const BorderSide(color: AppTheme.errorColor, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide:
                    const BorderSide(color: AppTheme.errorColor, width: 2),
              ),
            ),
            onChanged: _searchProductsHandler,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Cargando productos...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppTheme.textDisabled,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            const Text(
              'No hay productos disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            const Text(
              'Sincronice desde la API para cargar productos',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            CustomButton(
              text: 'Sincronizar desde API',
              onPressed: _syncProductsFromApi,
              icon: Icons.cloud_download,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar el número de columnas según el ancho
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppTheme.spacingMedium,
            mainAxisSpacing: AppTheme.spacingMedium,
            childAspectRatio: 0.75, // Ajustar según necesidad
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return ProductCard(
              product: product,
              onTap: () {
                _showProductDetails(product);
              },
            );
          },
        );
      },
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusMedium),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        color: AppTheme.surfaceColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(color: AppTheme.borderColor, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.salePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: product.isActive
                          ? AppTheme.successColor
                          : AppTheme.textDisabled,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: product.isActive
                              ? AppTheme.successColor
                              : AppTheme.textDisabled,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: product.isActive
                              ? AppTheme.successColor
                              : AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // Description
            if (product.description != null &&
                product.description!.isNotEmpty) ...[
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                product.description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
            ],

            // Additional Info
            if (product.formulaCode != null) ...[
              Row(
                children: [
                  const Icon(Icons.qr_code,
                      color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: AppTheme.spacingSmall),
                  const Text(
                    'Código: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    product.formulaCode!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
