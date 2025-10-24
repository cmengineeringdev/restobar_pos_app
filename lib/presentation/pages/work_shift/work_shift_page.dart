import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/auth_state_notifier.dart';
import '../../../core/providers/point_of_sale_state_notifier.dart';
import '../../../core/providers/work_shift_state_notifier.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class WorkShiftPage extends ConsumerStatefulWidget {
  const WorkShiftPage({super.key});

  @override
  ConsumerState<WorkShiftPage> createState() => _WorkShiftPageState();
}

class _WorkShiftPageState extends ConsumerState<WorkShiftPage> {
  bool _isCheckingRemote = false;
  Map<String, dynamic>? _salesSummary;

  @override
  void initState() {
    super.initState();
    // Cargar punto de venta y verificar turno activo cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    // Cargar el usuario actual
    await ref.read(authStateProvider.notifier).loadCurrentUser();
    
    // Cargar el punto de venta seleccionado desde la base de datos
    await ref.read(pointOfSaleStateProvider.notifier).loadSelectedPointOfSale();
    
    // Luego verificar el turno activo
    await _checkActiveWorkShift();
  }

  Future<void> _checkActiveWorkShift() async {
    final pointOfSaleState = ref.read(pointOfSaleStateProvider);

    if (pointOfSaleState.selectedPointOfSale == null) {
      _showErrorSnackBar('No hay punto de venta seleccionado');
      return;
    }

    setState(() {
      _isCheckingRemote = true;
    });

    try {
      // Primero verificar en remoto
      await ref.read(workShiftStateProvider.notifier).checkActiveWorkShiftRemote(
            pointOfSaleState.selectedPointOfSale!.id,
          );

      // Si hay turno activo, cargar el resumen de ventas
      final workShiftState = ref.read(workShiftStateProvider);
      if (workShiftState.hasActiveShift && workShiftState.activeWorkShift != null) {
        await _loadSalesSummary(workShiftState.activeWorkShift!.localId!);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al verificar turno activo: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingRemote = false;
        });
      }
    }
  }

  Future<void> _loadSalesSummary(int workShiftId) async {
    try {
      final orderRepository = ref.read(orderRepositoryProvider);

      // Obtener el resumen de ventas desde el repositorio
      final summary = await orderRepository.getWorkShiftSalesSummary(workShiftId);

      if (mounted) {
        setState(() {
          _salesSummary = summary;
        });
      }
    } catch (e) {
      print('ERROR: Error al cargar resumen de ventas: $e');
    }
  }

  Future<void> _openWorkShift() async {
    final pointOfSaleState = ref.read(pointOfSaleStateProvider);
    final authState = ref.read(authStateProvider);

    if (pointOfSaleState.selectedPointOfSale == null) {
      _showErrorSnackBar('No hay punto de venta seleccionado');
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        title: const Text(
          'Iniciar Turno',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Está seguro de que desea iniciar un nuevo turno en ${pointOfSaleState.selectedPointOfSale!.name}?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // El companyId lo determina automáticamente el servidor
      await ref.read(workShiftStateProvider.notifier).openWorkShift(
            pointOfSaleId: pointOfSaleState.selectedPointOfSale!.id,
            userId: authState.user?.userId,
          );

      if (mounted) {
        _showSuccessSnackBar('Turno iniciado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        duration: const Duration(seconds: 3),
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('d MMM yyyy, hh:mm a', 'es_ES').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final workShiftState = ref.watch(workShiftStateProvider);
    final pointOfSaleState = ref.watch(pointOfSaleStateProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.borderColor,
            height: 1,
          ),
        ),
        title: const Text(
          'Gestión de Turnos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _isCheckingRemote || workShiftState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : Row(
              children: [
                // Columna izquierda: Información del turno
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Información del punto de venta
                        _buildInfoCard(
                          title: 'Punto de Venta',
                          icon: Icons.store,
                          content: pointOfSaleState.selectedPointOfSale?.name ??
                              'No seleccionado',
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),

                        // Información del usuario
                        _buildInfoCard(
                          title: 'Usuario',
                          icon: Icons.person,
                          content: authState.user?.fullName ?? 'No disponible',
                        ),
                        const SizedBox(height: AppTheme.spacingLarge),

                        // Estado del turno
                        if (workShiftState.hasActiveShift &&
                            workShiftState.activeWorkShift != null)
                          _buildActiveWorkShiftCard(workShiftState.activeWorkShift!)
                        else
                          _buildNoActiveWorkShiftCard(),
                      ],
                    ),
                  ),
                ),

                // Divisor vertical
                Container(
                  width: 1,
                  color: AppTheme.borderColor,
                ),

                // Columna derecha: Resumen de ventas
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: workShiftState.hasActiveShift &&
                            workShiftState.activeWorkShift != null
                        ? _buildSalesSummary(workShiftState.activeWorkShift!)
                        : _buildNoSalesMessage(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkShiftCard(workShift) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turno Activo',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.access_time,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildWorkShiftDetailRow(
            'ID Remoto:',
            workShift.remoteId?.toString() ?? 'N/A',
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildWorkShiftDetailRow(
            'Fecha de Apertura:',
            _formatDateTime(workShift.openDate),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildWorkShiftDetailRow(
            'Punto de Venta:',
            workShift.pointOfSaleId.toString(),
          ),
          if (workShift.userId != null) ...[
            const SizedBox(height: AppTheme.spacingSmall),
            _buildWorkShiftDetailRow(
              'Usuario:',
              workShift.userId!,
            ),
          ],
          const SizedBox(height: AppTheme.spacingMedium),
          const Divider(color: AppTheme.borderColor),
          const SizedBox(height: AppTheme.spacingMedium),
          // Botón para cerrar turno
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _closeWorkShift(workShift.pointOfSaleId),
              icon: const Icon(Icons.stop, size: 18),
              label: const Text(
                'Cerrar Turno',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _closeWorkShift(int pointOfSaleId) async {
    print('DEBUG PAGE: _closeWorkShift called with pointOfSaleId: $pointOfSaleId');
    
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        title: const Text(
          'Cerrar Turno',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Está seguro de que desea cerrar el turno actual?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('DEBUG PAGE: Cancelar presionado');
              Navigator.of(context).pop(false);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('DEBUG PAGE: Cerrar Turno confirmado');
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              elevation: 0,
            ),
            child: const Text('Cerrar Turno'),
          ),
        ],
      ),
    );

    print('DEBUG PAGE: Confirmed: $confirmed');
    
    if (confirmed != true) {
      print('DEBUG PAGE: Operación cancelada');
      return;
    }

    print('DEBUG PAGE: Llamando a workShiftStateProvider.notifier.closeWorkShift');
    try {
      await ref.read(workShiftStateProvider.notifier).closeWorkShift(pointOfSaleId);

      print('DEBUG PAGE: Turno cerrado exitosamente');
      if (mounted) {
        _showSuccessSnackBar('Turno cerrado exitosamente');
      }
    } catch (e) {
      print('DEBUG PAGE: Error al cerrar turno: $e');
      if (mounted) {
        _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Widget _buildWorkShiftDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoActiveWorkShiftCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.access_time,
            color: AppTheme.textSecondary,
            size: 40,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          const Text(
            'No hay turno activo',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          const Text(
            'Debe iniciar un turno para comenzar a operar',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openWorkShift,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text(
                'Iniciar Turno',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummary(workShift) {
    if (_salesSummary == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    final orders = _salesSummary!['orders'] as Map<String, dynamic>;
    final payments = _salesSummary!['payments'] as List<Map<String, dynamic>>;

    final completedOrders = orders['completed_orders'] as int;
    final activeOrders = orders['active_orders'] as int;
    final cancelledOrders = orders['cancelled_orders'] as int;
    final totalOrders = orders['total_orders'] as int;
    final totalSales = (orders['total_sales'] as num).toDouble();
    final totalSubtotal = (orders['total_subtotal'] as num).toDouble();
    final totalTax = (orders['total_tax'] as num).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          children: [
            const Icon(Icons.analytics, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text(
              'Resumen de Ventas',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              color: AppTheme.primaryColor,
              onPressed: () => _loadSalesSummary(workShift.localId!),
              tooltip: 'Actualizar',
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Total de ventas
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(color: AppTheme.borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Ventas',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(totalSales),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Órdenes
        _buildSectionTitle('Órdenes'),
        const SizedBox(height: AppTheme.spacingSmall),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Completadas',
                completedOrders.toString(),
                Icons.check_circle_outline,
                AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: _buildStatCard(
                'Activas',
                activeOrders.toString(),
                Icons.pending_outlined,
                AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Canceladas',
                cancelledOrders.toString(),
                Icons.cancel_outlined,
                AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: _buildStatCard(
                'Total',
                totalOrders.toString(),
                Icons.receipt_long_outlined,
                AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Desglose
        _buildSectionTitle('Desglose'),
        const SizedBox(height: AppTheme.spacingSmall),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              _buildDetailRow('Subtotal', CurrencyFormatter.format(totalSubtotal)),
              const SizedBox(height: 8),
              _buildDetailRow('Imp. Consumo', CurrencyFormatter.format(totalTax)),
              const Divider(height: 20, color: AppTheme.borderColor),
              _buildDetailRow(
                'Total',
                CurrencyFormatter.format(totalSales),
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Métodos de pago
        if (payments.isNotEmpty) ...[
          _buildSectionTitle('Métodos de Pago'),
          const SizedBox(height: AppTheme.spacingSmall),
          ...payments.map((payment) {
            final method = payment['payment_method'] as String;
            final count = payment['count'] as int;
            final total = (payment['total'] as num).toDouble();

            String methodName;
            IconData methodIcon;

            switch (method) {
              case 'cash':
                methodName = 'Efectivo';
                methodIcon = Icons.money;
                break;
              case 'credit_card':
                methodName = 'Tarjeta de Crédito';
                methodIcon = Icons.credit_card;
                break;
              case 'debit_card':
                methodName = 'Tarjeta de Débito';
                methodIcon = Icons.payment;
                break;
              default:
                methodName = method;
                methodIcon = Icons.payment;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Icon(methodIcon, color: AppTheme.textSecondary, size: 24),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          methodName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$count transacciones',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(total),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildNoSalesMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppTheme.textDisabled,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          const Text(
            'No hay turno activo',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          const Text(
            'Inicie un turno para ver el resumen de ventas',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 20),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

