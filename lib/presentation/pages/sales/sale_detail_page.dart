import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/currency_formatter.dart';

class SaleDetailPage extends ConsumerStatefulWidget {
  final int orderId;

  const SaleDetailPage({super.key, required this.orderId});

  @override
  ConsumerState<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends ConsumerState<SaleDetailPage> {
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _orderItems = [];
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderDetails();
    });
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);

    try {
      final orderRepository = ref.read(orderRepositoryProvider);
      final orderDetails = await orderRepository.getOrderWithDetails(widget.orderId);

      if (mounted) {
        setState(() {
          _order = orderDetails['order'] as Map<String, dynamic>?;
          _orderItems = orderDetails['items'] as List<Map<String, dynamic>>;
          _payments = orderDetails['payments'] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error al cargar detalles: $e');
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
      return DateFormat('d MMM yyyy, hh:mm:ss a', 'es_ES').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Efectivo';
      case 'credit_card':
        return 'Tarjeta de Crédito';
      case 'debit_card':
        return 'Tarjeta de Débito';
      default:
        return method;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money;
      case 'credit_card':
        return Icons.credit_card;
      case 'debit_card':
        return Icons.payment;
      default:
        return Icons.payment;
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
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.borderColor,
            height: 1,
          ),
        ),
        title: Text(
          'Detalle Orden #${widget.orderId}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : _order == null
              ? const Center(
                  child: Text(
                    'Orden no encontrada',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información general
                      _buildInfoCard(),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Items de la orden
                      _buildSectionTitle('Items de la Orden'),
                      const SizedBox(height: AppTheme.spacingSmall),
                      ..._orderItems.map((item) => _buildOrderItem(item)),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Totales
                      _buildTotalsCard(),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Botón facturar venta
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar funcionalidad de facturación
                          },
                          icon: const Icon(Icons.receipt_long, size: 18),
                          label: const Text('Facturar venta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Pagos
                      if (_payments.isNotEmpty) ...[
                        _buildSectionTitle('Pagos Registrados'),
                        const SizedBox(height: AppTheme.spacingSmall),
                        ..._payments.map((payment) => _buildPaymentItem(payment)),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard() {
    final tableId = _order!['table_id'] as int;
    final status = _order!['status'] as String;
    final notes = _order!['notes'] as String?;
    final createdAt = _order!['created_at'] as String?;
    final closedAt = _order!['closed_at'] as String?;

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
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Información General',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildInfoRow('Mesa:', 'Mesa $tableId'),
          const SizedBox(height: 8),
          _buildInfoRow('Estado:', _getStatusText(status)),
          const SizedBox(height: 8),
          _buildInfoRow('Creada:', _formatDateTime(createdAt)),
          if (closedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Cerrada:', _formatDateTime(closedAt)),
          ],
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppTheme.borderColor),
            const SizedBox(height: 8),
            const Text(
              'Notas:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notes,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'Abierta';
      case 'preparing':
        return 'En preparación';
      case 'ready':
        return 'Lista';
      case 'delivered':
        return 'Entregada';
      case 'closed':
        return 'Cerrada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final productName = item['product_name'] as String;
    final quantity = item['quantity'] as int;
    final unitPrice = (item['unit_price'] as num).toDouble();
    final subtotal = (item['subtotal'] as num).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      padding: const EdgeInsets.all(AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${quantity}x',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${CurrencyFormatter.format(unitPrice)} c/u',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(subtotal),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard() {
    final subtotal = (_order!['subtotal'] as num).toDouble();
    final tax = (_order!['tax'] as num).toDouble();
    final total = (_order!['total'] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', CurrencyFormatter.format(subtotal)),
          const SizedBox(height: 8),
          _buildTotalRow('Imp. Consumo', CurrencyFormatter.format(tax)),
          const Divider(height: 20, color: AppTheme.borderColor),
          _buildTotalRow(
            'Total',
            CurrencyFormatter.format(total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
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
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    final method = payment['payment_method'] as String;
    final amount = (payment['amount'] as num).toDouble();
    final notes = payment['notes'] as String?;
    final createdAt = payment['created_at'] as String?;

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
          Icon(
            _getPaymentMethodIcon(method),
            color: AppTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPaymentMethodName(method),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
