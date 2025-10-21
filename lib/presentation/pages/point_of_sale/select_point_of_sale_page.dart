import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/point_of_sale_state_notifier.dart';
import '../../../core/providers/table_state_notifier.dart';
import '../../../domain/entities/point_of_sale.dart';
import '../home/home_page.dart';

class SelectPointOfSalePage extends ConsumerStatefulWidget {
  const SelectPointOfSalePage({super.key});

  @override
  ConsumerState<SelectPointOfSalePage> createState() =>
      _SelectPointOfSalePageState();
}

class _SelectPointOfSalePageState
    extends ConsumerState<SelectPointOfSalePage> {
  @override
  void initState() {
    super.initState();
    // Load points of sale when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pointOfSaleStateProvider.notifier).loadPointsOfSale();
    });
  }

  Future<void> _handleSelection(PointOfSale pos) async {
    try {
      // Seleccionar punto de venta
      await ref.read(pointOfSaleStateProvider.notifier).selectPointOfSale(pos);

      // Crear las mesas para el punto de venta basado en numberOfTables
      print('DEBUG: Creando ${pos.numberOfTables} mesas para punto de venta ${pos.id}');
      await ref.read(tableStateProvider.notifier).createTablesForPointOfSale(
            pos.id,
            pos.numberOfTables,
          );

      if (mounted) {
        // Navigate to home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Punto de venta seleccionado: ${pos.name}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error al seleccionar punto de venta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(pointOfSaleStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: posState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : posState.availablePointsOfSale.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.store_outlined,
                        size: 64,
                        color: AppTheme.textDisabled,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        posState.error ?? 'No hay puntos de venta disponibles',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref
                            .read(pointOfSaleStateProvider.notifier)
                            .loadPointsOfSale(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Recargar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona tu punto de venta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Esta selección se guardará y se usará para todas las operaciones',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(posState.availablePointsOfSale.length,
                          (index) {
                        final pos = posState.availablePointsOfSale[index];
                        final isSelected =
                            posState.selectedPointOfSale?.id == pos.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 0,
                            color: AppTheme.surfaceColor,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                              side: isSelected
                                  ? const BorderSide(
                                      color: AppTheme.primaryColor,
                                      width: 2,
                                    )
                                  : const BorderSide(
                                      color: AppTheme.borderColor,
                                      width: 1,
                                    ),
                            ),
                            child: InkWell(
                              onTap: () => _handleSelection(pos),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Icon
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                                .withOpacity(0.1)
                                            : AppTheme.backgroundColor,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : AppTheme.borderColor,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSmall),
                                      ),
                                      child: Icon(
                                        Icons.store,
                                        size: 32,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pos.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? AppTheme.primaryColor
                                                  : AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            pos.address,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.table_restaurant,
                                                size: 16,
                                                color: AppTheme.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${pos.numberOfTables} mesas',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              if (pos.managerName != null) ...[
                                                const SizedBox(width: 16),
                                                const Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: AppTheme.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    pos.managerName!,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme
                                                          .textSecondary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Selection indicator
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                        color: AppTheme.textDisabled,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
