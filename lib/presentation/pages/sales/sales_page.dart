import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/work_shift_state_notifier.dart';
import '../../../core/utils/currency_formatter.dart';
import 'sale_detail_page.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _closedOrders = [];
  List<Map<String, dynamic>> _cancelledOrders = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final workShiftState = ref.read(workShiftStateProvider);
      if (workShiftState.activeWorkShift == null) {
        throw Exception('No hay turno activo');
      }

      final orderRepository = ref.read(orderRepositoryProvider);
      final workShiftId = workShiftState.activeWorkShift!.localId!;

      final closedOrders = await orderRepository.getClosedOrdersByWorkShift(workShiftId);
      final cancelledOrders = await orderRepository.getCancelledOrdersByWorkShift(workShiftId);

      if (mounted) {
        setState(() {
          _closedOrders = closedOrders;
          _cancelledOrders = cancelledOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error al cargar ventas: $e');
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

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('d MMM yyyy, hh:mm a', 'es_ES').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(
                color: AppTheme.borderColor,
                height: 1,
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Completadas'),
                  Tab(text: 'Canceladas'),
                ],
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
        title: const Text(
          'Ventas del Turno',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab de órdenes completadas
                _closedOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppTheme.textDisabled,
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),
                            const Text(
                              'No hay ventas completadas',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSmall),
                            const Text(
                              'Las órdenes completadas aparecerán aquí',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        itemCount: _closedOrders.length,
                        itemBuilder: (context, index) {
                          final order = _closedOrders[index];
                          return _buildOrderCard(order, isCompleted: true);
                        },
                      ),
                // Tab de órdenes canceladas
                _cancelledOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              size: 64,
                              color: AppTheme.textDisabled,
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),
                            const Text(
                              'No hay ventas canceladas',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSmall),
                            const Text(
                              'Las órdenes canceladas aparecerán aquí',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        itemCount: _cancelledOrders.length,
                        itemBuilder: (context, index) {
                          final order = _cancelledOrders[index];
                          return _buildOrderCard(order, isCompleted: false);
                        },
                      ),
              ],
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, {required bool isCompleted}) {
    final orderId = order['id'] as int;
    final tableId = order['table_id'] as int;
    final total = (order['total'] as num).toDouble();
    final closedAt = order['closed_at'] as String?;
    final notes = order['notes'] as String?;
    final cancellationReason = order['cancellation_reason'] as String?;

    final statusColor = isCompleted ? AppTheme.successColor : AppTheme.errorColor;
    final statusBgColor = isCompleted
        ? AppTheme.successColor.withOpacity(0.1)
        : AppTheme.errorColor.withOpacity(0.1);
    final statusText = isCompleted ? 'Completada' : 'Cancelada';
    final iconColor = isCompleted ? AppTheme.primaryColor : AppTheme.errorColor;
    final iconBgColor = isCompleted
        ? AppTheme.primaryColor.withOpacity(0.1)
        : AppTheme.errorColor.withOpacity(0.1);

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      color: AppTheme.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleDetailPage(orderId: orderId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  isCompleted ? Icons.receipt_long : Icons.cancel,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Orden #$orderId',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mesa $tableId',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (!isCompleted && cancellationReason != null && cancellationReason.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Motivo: $cancellationReason',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.errorColor,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else if (isCompleted && notes != null && notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        notes,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(closedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Total and arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(total),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppTheme.primaryColor : AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
