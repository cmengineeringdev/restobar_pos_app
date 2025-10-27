import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/auth_state_notifier.dart';
import '../../../core/providers/point_of_sale_state_notifier.dart';
import '../../../core/providers/product_state_notifier.dart';
import '../../../core/providers/work_shift_state_notifier.dart';
import '../../../core/utils/message_helper.dart';
import '../auth/login_page.dart';
import '../sales/sales_page.dart';
import '../tables/tables_page.dart';
import '../work_shift/work_shift_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load current user and work shift when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    // Cargar usuario
    await ref.read(authStateProvider.notifier).loadCurrentUser();

    // Cargar punto de venta y verificar turno activo
    await ref.read(pointOfSaleStateProvider.notifier).loadSelectedPointOfSale();
    final pointOfSaleState = ref.read(pointOfSaleStateProvider);

    if (pointOfSaleState.selectedPointOfSale != null) {
      try {
        await ref.read(workShiftStateProvider.notifier).checkActiveWorkShiftRemote(
              pointOfSaleState.selectedPointOfSale!.id,
            );
      } catch (e) {
        // Error al verificar turno, no hacer nada 
      }
    }

    // Sincronizar productos automáticamente si hay punto de venta seleccionado
    if (pointOfSaleState.selectedPointOfSale != null) {
      try {
        await ref.read(productStateProvider.notifier).syncProducts(
          pointOfSaleId: pointOfSaleState.selectedPointOfSale!.id,
        );
      } catch (e) {
        // Error al sincronizar productos, continuar sin mostrar error
        print('Error sincronizando productos: $e');
      }
    }
  }

  Future<void> _syncProductsFromApi() async {
    final pointOfSaleState = ref.read(pointOfSaleStateProvider);

    if (pointOfSaleState.selectedPointOfSale == null) {
      context.showError('No hay punto de venta seleccionado');
      return;
    }

    try {
      await ref.read(productStateProvider.notifier).syncProducts(
        pointOfSaleId: pointOfSaleState.selectedPointOfSale!.id,
      );

      if (mounted) {
        final productState = ref.read(productStateProvider);
        if (productState.successMessage != null) {
          context.showSuccess(productState.successMessage!);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showError('Error al sincronizar productos: $e');
      }
    }
  }

  void _showModuleInProgress(String moduleName) {
    context.showWarning('El módulo "$moduleName" está en proceso de desarrollo');
  }

  Future<void> _navigateToOrders() async {
    final workShiftState = ref.read(workShiftStateProvider);

    // Validar que hay un turno abierto
    if (!workShiftState.hasActiveShift) {
      context.showWarning(
        'Debe abrir un turno antes de gestionar pedidos',
        action: SnackBarAction(
          label: 'Abrir Turno',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkShiftPage(),
              ),
            );
          },
        ),
      );
      return;
    }

    // Sincronizar productos antes de navegar
    final pointOfSaleState = ref.read(pointOfSaleStateProvider);
    if (pointOfSaleState.selectedPointOfSale != null) {
      try {
        await ref.read(productStateProvider.notifier).syncProducts(
          pointOfSaleId: pointOfSaleState.selectedPointOfSale!.id,
        );
      } catch (e) {
        // Error al sincronizar, continuar de todos modos
        print('Error sincronizando productos: $e');
      }
    }

    if (!mounted) return;

    // Si hay turno abierto, navegar a la vista de mesas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TablesPage(),
      ),
    );
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
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final productState = ref.watch(productStateProvider);
    final workShiftState = ref.watch(workShiftStateProvider);
    final pointOfSaleState = ref.watch(pointOfSaleStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(authState.user),
      body: Column(
        children: [
          // Syncing indicator
          if (productState.isSyncing)
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

          // Work Shift Status Banner
          if (pointOfSaleState.selectedPointOfSale != null)
            _buildWorkShiftBanner(workShiftState, pointOfSaleState.selectedPointOfSale!.name),

          // Module Cards Grid
          Expanded(child: _buildModulesGrid()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic currentUser) {
    final productState = ref.watch(productStateProvider);

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
              if (currentUser != null)
                Text(
                  currentUser.firstName,
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
          onPressed: productState.isSyncing ? null : _syncProductsFromApi,
          tooltip: 'Sincronizar productos desde API',
        ),

        // User menu
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              currentUser?.firstName.substring(0, 1).toUpperCase() ?? 'U',
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
            if (currentUser != null)
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${currentUser.username}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentUser.companyCode,
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

  Widget _buildWorkShiftBanner(WorkShiftState workShiftState, String pointOfSaleName) {
    final hasActiveShift = workShiftState.hasActiveShift && workShiftState.activeWorkShift != null;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: hasActiveShift ? AppTheme.successColor : AppTheme.errorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          
          // Text
          Expanded(
            child: Text(
              hasActiveShift ? 'Turno abierto' : 'Sin turno activo',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          // Icon
          Icon(
            Icons.access_time,
            size: 16,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar el número de columnas según el ancho
        int crossAxisCount;
        if (constraints.maxWidth > 1000) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          padding: const EdgeInsets.all(AppTheme.spacingXLarge),
          mainAxisSpacing: AppTheme.spacingMedium,
          crossAxisSpacing: AppTheme.spacingMedium,
          childAspectRatio: 1.5,
          children: [
            _buildModuleCard(
              title: 'Pedidos',
              description: 'Gestiona los pedidos de las mesas',
              icon: Icons.receipt_long_outlined,
              onTap: _navigateToOrders,
            ),
            _buildModuleCard(
              title: 'Turno',
              description: 'Controla el inicio y cierre de turno',
              icon: Icons.access_time_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkShiftPage(),
                  ),
                );
              },
            ),
            _buildModuleCard(
              title: 'Ventas',
              description: 'Consulta las ventas del turno actual',
              icon: Icons.point_of_sale_outlined,
              onTap: () {
                final workShiftState = ref.read(workShiftStateProvider);
                if (!workShiftState.hasActiveShift) {
                  context.showError('Debe abrir un turno para ver las ventas');
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesPage(),
                  ),
                );
              },
            ),
            _buildModuleCard(
              title: 'Domicilios',
              description: 'Administra los pedidos a domicilio',
              icon: Icons.delivery_dining_outlined,
              onTap: () => _showModuleInProgress('Domicilios'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXSmall),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
