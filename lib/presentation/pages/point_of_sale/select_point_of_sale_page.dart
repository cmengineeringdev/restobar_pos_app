import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/injection/injection_container.dart';
import '../../../domain/entities/point_of_sale.dart';
import '../../../domain/usecases/get_points_of_sale.dart';
import '../../../domain/usecases/select_point_of_sale.dart';
import '../home/home_page.dart';

class SelectPointOfSalePage extends StatefulWidget {
  const SelectPointOfSalePage({super.key});

  @override
  State<SelectPointOfSalePage> createState() => _SelectPointOfSalePageState();
}

class _SelectPointOfSalePageState extends State<SelectPointOfSalePage> {
  final InjectionContainer _container = InjectionContainer();
  late final GetPointsOfSale _getPointsOfSale;
  late final SelectPointOfSale _selectPointOfSale;

  List<PointOfSale> _pointsOfSale = [];
  bool _isLoading = true;
  PointOfSale? _selectedPos;

  @override
  void initState() {
    super.initState();
    _getPointsOfSale = _container.getPointsOfSale;
    _selectPointOfSale = _container.selectPointOfSale;
    _loadPointsOfSale();
  }

  Future<void> _loadPointsOfSale() async {
    setState(() => _isLoading = true);

    try {
      final pointsOfSale = await _getPointsOfSale();
      setState(() {
        _pointsOfSale = pointsOfSale;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los puntos de venta: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleSelection(PointOfSale pos) async {
    setState(() => _selectedPos = pos);

    try {
      await _selectPointOfSale(pos);

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
      setState(() => _selectedPos = null);
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _pointsOfSale.isEmpty
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
                      const Text(
                        'No hay puntos de venta disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadPointsOfSale,
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
                      ...List.generate(_pointsOfSale.length, (index) {
                        final pos = _pointsOfSale[index];
                        final isSelected = _selectedPos?.id == pos.id;

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
