import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/order_state_notifier.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/table_state_notifier.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/order.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final Order order;

  const PaymentPage({super.key, required this.order});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String _selectedPaymentMethod = 'cash';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;
  List<Map<String, dynamic>> _payments = [];
  double _totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    // Por defecto, establecer el monto al total pendiente
    _amountController.text = widget.order.total.toStringAsFixed(0);
  }

  double get _remaining => widget.order.total - _totalPaid;
  bool get _isFullyPaid => _remaining <= 0.01; // Pequeña tolerancia para decimales

  void _addPayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Por favor ingrese un monto válido', isError: true);
      return;
    }

    if (amount > _remaining) {
      _showSnackBar('El monto excede el total pendiente', isError: true);
      return;
    }

    setState(() {
      _totalPaid += amount;
      _payments.add({
        'method': _selectedPaymentMethod,
        'amount': amount,
        'notes': _notesController.text,
      });
      _notesController.clear();

      final newRemaining = _remaining;
      if (newRemaining > 0) {
        _amountController.text = newRemaining.toStringAsFixed(0);
      } else {
        _amountController.clear();
      }
    });

    _showSnackBar('Pago agregado', isError: false);
  }

  void _removePayment(int index) {
    setState(() {
      final payment = _payments[index];
      _totalPaid -= payment['amount'] as double;
      _payments.removeAt(index);

      if (_payments.isEmpty) {
        _amountController.text = widget.order.total.toStringAsFixed(0);
      } else {
        final newRemaining = _remaining;
        if (newRemaining > 0) {
          _amountController.text = newRemaining.toStringAsFixed(0);
        }
      }
    });

    _showSnackBar('Pago eliminado', isError: false);
  }

  Future<void> _confirmPayments() async {
    if (_payments.isEmpty) {
      _showSnackBar('No hay pagos para confirmar', isError: true);
      return;
    }

    if (!_isFullyPaid) {
      _showSnackBar('Debe completar el pago total de la orden', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final createPayment = ref.read(createPaymentProvider);

      // Guardar todos los pagos en la base de datos
      for (final payment in _payments) {
        await createPayment(
          orderId: widget.order.id!,
          paymentMethod: payment['method'] as String,
          amount: payment['amount'] as double,
          notes: (payment['notes'] as String).isEmpty ? null : payment['notes'] as String,
        );
      }

      if (!mounted) return;

      // Cerrar orden y liberar mesa
      final completeOrder = ref.read(completeOrderProvider);
      await completeOrder(
        orderId: widget.order.id!,
        tableId: widget.order.tableId,
      );

      if (!mounted) return;

      // Limpiar el estado del pedido
      ref.read(orderStateProvider.notifier).clearOrder();

      // Actualizar el estado de la mesa localmente
      await ref.read(tableStateProvider.notifier).updateTableStatus(
        widget.order.tableId,
        'available',
      );

      if (!mounted) return;

      _showSnackBar('Orden completada exitosamente', isError: false);

      // Navegar al inicio (cerrar todas las pantallas hasta la raíz)
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error al confirmar pagos: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.borderColor, height: 1),
        ),
        title: const Text(
          'Procesar Pago',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Row(
        children: [
          // Lado izquierdo: Métodos de pago y formulario
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Métodos de pago
                  const Text(
                    'Método de Pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildPaymentMethods(),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Monto a pagar
                  const Text(
                    'Monto a Pagar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  TextField(
                    controller: _amountController,
                    enabled: !_isFullyPaid,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      hintText: '0.00',
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Notas
                  const Text(
                    'Notas (Opcional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  TextField(
                    controller: _notesController,
                    enabled: !_isFullyPaid,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ej: Pago cliente 1, cambio, etc...',
                      hintStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Botones de acción
                  Row(
                    children: [
                      // Botón agregar pago
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _addPayment,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Agregar Pago'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.surfaceColor,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              side: const BorderSide(color: AppTheme.primaryColor),
                            ),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      // Botón confirmar pagos
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_isProcessing || _payments.isEmpty || !_isFullyPaid) ? null : _confirmPayments,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle, size: 20),
                          label: Text(_isProcessing ? 'Procesando...' : 'Confirmar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                    
                  // Pagos registrados
                  if (_payments.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingLarge),
                    const Divider(color: AppTheme.borderColor),
                    const SizedBox(height: AppTheme.spacingMedium),
                    const Text(
                      'Pagos Agregados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    ..._payments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final payment = entry.value;
                      return _buildPaymentTile(payment, index);
                    }),
                  ],
                ],
              ),
            ),
          ),

          // Lado derecho: Resumen de la orden
          Container(
            width: 350,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                left: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
            ),
            child: _buildOrderSummary(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'id': 'cash', 'name': 'Efectivo', 'icon': Icons.money},
      {'id': 'credit_card', 'name': 'Tarjeta de Crédito', 'icon': Icons.credit_card},
      {'id': 'debit_card', 'name': 'Tarjeta de Débito', 'icon': Icons.payment},
    ];

    return Wrap(
      spacing: AppTheme.spacingMedium,
      runSpacing: AppTheme.spacingSmall,
      children: methods.map((method) {
        final isSelected = _selectedPaymentMethod == method['id'];
        return InkWell(
          onTap: _isFullyPaid ? null : () {
            setState(() {
              _selectedPaymentMethod = method['id'] as String;
            });
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryColor.withOpacity(0.1) 
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  method['icon'] as IconData,
                  size: 32,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  method['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
          ),
          child: const Row(
            children: [
              Icon(Icons.receipt_long, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Resumen de Pago',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Detalles
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Orden #', '${widget.order.id}', isBold: false),
                const SizedBox(height: 8),
                const Divider(color: AppTheme.borderColor),
                const SizedBox(height: 12),
                _buildSummaryRow('Subtotal', CurrencyFormatter.format(widget.order.subtotal)),
                const SizedBox(height: 8),
                _buildSummaryRow('Imp. Consumo', CurrencyFormatter.format(widget.order.tax)),
                const SizedBox(height: 12),
                const Divider(color: AppTheme.borderColor, thickness: 2),
                const SizedBox(height: 12),
                _buildSummaryRow('Total', CurrencyFormatter.format(widget.order.total), isBold: true, isLarge: true),
                
                if (_totalPaid > 0) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.borderColor),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Pagado', 
                    CurrencyFormatter.format(_totalPaid),
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Pendiente', 
                    CurrencyFormatter.format(_remaining),
                    color: _isFullyPaid ? AppTheme.successColor : AppTheme.warningColor,
                    isBold: true,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Status indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isFullyPaid
                ? AppTheme.successColor.withOpacity(0.1)
                : AppTheme.warningColor.withOpacity(0.1),
            border: Border(
              top: BorderSide(
                color: _isFullyPaid ? AppTheme.successColor : AppTheme.warningColor,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isFullyPaid ? Icons.check_circle : Icons.pending,
                color: _isFullyPaid ? AppTheme.successColor : AppTheme.warningColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _isFullyPaid ? 'LISTO PARA CONFIRMAR' : 'PAGO PENDIENTE',
                style: TextStyle(
                  color: _isFullyPaid ? AppTheme.successColor : AppTheme.warningColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLarge = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color ?? AppTheme.textSecondary,
            fontSize: isLarge ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? (isBold ? AppTheme.primaryColor : AppTheme.textPrimary),
            fontSize: isLarge ? 20 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTile(Map<String, dynamic> payment, int index) {
    String methodName;
    IconData methodIcon;

    switch (payment['method']) {
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
        methodName = 'Desconocido';
        methodIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(methodIcon, color: AppTheme.textSecondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  methodName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (payment['notes'] != null && (payment['notes'] as String).isNotEmpty)
                  Text(
                    payment['notes'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(payment['amount'] as double),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _isProcessing ? null : () => _removePayment(index),
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppTheme.errorColor,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}