import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/point_of_sale_state_notifier.dart';
import '../../../core/providers/table_state_notifier.dart';
import '../orders/create_order_page.dart';

class TablesPage extends ConsumerStatefulWidget {
  const TablesPage({super.key});

  @override
  ConsumerState<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends ConsumerState<TablesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTables();
    });
  }

  Future<void> _loadTables() async {
    final pointOfSaleState = ref.read(pointOfSaleStateProvider);
    
    if (pointOfSaleState.selectedPointOfSale != null) {
      try {
        await ref.read(tableStateProvider.notifier).loadTables(
              pointOfSaleState.selectedPointOfSale!.id,
            );
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Error al cargar mesas: ${e.toString().replaceAll('Exception: ', '')}');
        }
      }
    }
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableState = ref.watch(tableStateProvider);
    final pointOfSaleState = ref.watch(pointOfSaleStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.borderColor,
            height: 1,
          ),
        ),
        title: const Text(
          'Mesas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: tableState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : tableState.tables.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_restaurant,
                        size: 64,
                        color: AppTheme.textDisabled,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay mesas disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pointOfSaleState.selectedPointOfSale?.name ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header con información del punto de venta
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      color: AppTheme.surfaceColor,
                      child: Row(
                        children: [
                          Icon(
                            Icons.store,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            pointOfSaleState.selectedPointOfSale?.name ?? '',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          _buildTableStats(),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppTheme.borderColor),
                    
                    // Grid de mesas
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingLarge),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: AppTheme.spacingMedium,
                          mainAxisSpacing: AppTheme.spacingMedium,
                        ),
                        itemCount: tableState.tables.length,
                        itemBuilder: (context, index) {
                          final table = tableState.tables[index];
                          return _buildTableCard(table);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTableStats() {
    final tableState = ref.watch(tableStateProvider);
    final availableTables = tableState.tables.where((t) => t.status == 'available').length;
    final occupiedTables = tableState.tables.where((t) => t.status == 'occupied').length;

    return Row(
      children: [
        _buildStatChip(
          Icons.check_circle,
          availableTables.toString(),
          AppTheme.successColor,
          'Disponibles',
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        _buildStatChip(
          Icons.restaurant,
          occupiedTables.toString(),
          AppTheme.warningColor,
          'Ocupadas',
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String count, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(table) {
    final isAvailable = table.status == 'available';
    final backgroundColor = isAvailable 
        ? AppTheme.surfaceColor 
        : AppTheme.warningColor.withOpacity(0.1);
    final borderColor = isAvailable 
        ? AppTheme.borderColor 
        : AppTheme.warningColor;
    final statusColor = isAvailable 
        ? AppTheme.successColor 
        : AppTheme.warningColor;
    final statusText = isAvailable ? 'Disponible' : 'Ocupada';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateOrderPage(table: table),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de mesa
            Icon(
              Icons.table_restaurant,
              size: 32,
              color: isAvailable ? AppTheme.textSecondary : AppTheme.warningColor,
            ),
            const SizedBox(height: 6),
            
            // Número de mesa
            Text(
              'Mesa ${table.number}',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            
            // Estado
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

