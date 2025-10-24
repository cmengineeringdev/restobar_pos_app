import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/order_state_notifier.dart';
import '../../../core/providers/product_state_notifier.dart';
import '../../../core/providers/table_state_notifier.dart';
import '../../../core/providers/work_shift_state_notifier.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/table.dart' as table_entity;
import '../payment/payment_page.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  final table_entity.Table table;

  const CreateOrderPage({super.key, required this.table});

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrder();
    });
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _initializeOrder() async {
    if (!mounted) return;
    
    final workShiftState = ref.read(workShiftStateProvider);
    
    if (workShiftState.activeWorkShift == null) {
      return;
    }

    try {
      await ref.read(orderStateProvider.notifier).initializeOrderForTable(
            tableId: widget.table.id!,
            workShiftId: workShiftState.activeWorkShift!.localId!,
          );
      
      if (!mounted) return;
      
      // Cargar las notas del pedido si existen
      final orderState = ref.read(orderStateProvider);
      if (orderState.currentOrder?.notes != null) {
        _notesController.text = orderState.currentOrder!.notes!;
      }
    } catch (e) {
      // Error silencioso
    }
  }

  void _addProduct(product) {
    if (!mounted) return;
    
    try {
      ref.read(orderStateProvider.notifier).addProduct(
            productId: product.remoteId,
            productName: product.name,
            unitPrice: product.salePrice,
            quantity: 1,
          );
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _confirmOrder() async {
    if (!mounted) return;
    
    final orderState = ref.read(orderStateProvider);
    final workShiftState = ref.read(workShiftStateProvider);
    
    if (orderState.temporaryItems.isEmpty) {
      return;
    }

    if (workShiftState.activeWorkShift == null) {
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        title: const Text(
          '¿Preparar Pedido?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Se confirmará el pedido de la Mesa ${widget.table.number} y se marcará como ocupada.',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
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
              elevation: 0,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(orderStateProvider.notifier).confirmOrder(
            tableId: widget.table.id!,
            workShiftId: workShiftState.activeWorkShift!.localId!,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );
      
      // Actualizar el estado de la mesa en el tableStateProvider
      if (mounted) {
        await ref.read(tableStateProvider.notifier).updateTableStatus(
              widget.table.id!,
              'occupied',
            );
      }
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _proceedToPayment() async {
    if (!mounted) return;
    
    final orderState = ref.read(orderStateProvider);
    if (orderState.currentOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay un pedido activo'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Crear una copia de la orden con los totales actualizados del estado
    final orderWithTotals = orderState.currentOrder!.copyWith(
      subtotal: orderState.subtotal,
      tax: orderState.tax,
      total: orderState.total,
    );

    print('DEBUG PAYMENT: Navegando a pago con totales - Subtotal: ${orderWithTotals.subtotal}, Tax: ${orderWithTotals.tax}, Total: ${orderWithTotals.total}');

    // Navegar a la pantalla de pago
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(order: orderWithTotals),
      ),
    );

    // Si el pago fue completado, volver a la lista de mesas
    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showCancelOrderDialog() async {
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 24),
            SizedBox(width: 8),
            Text(
              '¿Cancelar Pedido?',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Se cancelará el pedido de la Mesa ${widget.table.number} y la mesa volverá a estar disponible. Esta acción no se puede deshacer.',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No, mantener pedido',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              elevation: 0,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(orderStateProvider.notifier).cancelOrder();
      
      if (!mounted) return;
      
      // Actualizar el estado de la mesa en el tableStateProvider
      await ref.read(tableStateProvider.notifier).updateTableStatus(
            widget.table.id!,
            'available',
          );
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido cancelado exitosamente'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Volver a la pantalla anterior
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar pedido: $e'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    // Limpiar estado temporal si no fue confirmado ANTES de salir
    try {
      final orderState = ref.read(orderStateProvider);
      if (!orderState.isConfirmed && orderState.temporaryItems.isNotEmpty) {
        print('DEBUG ORDER PAGE: Limpiando estado temporal al presionar back');
        ref.read(orderStateProvider.notifier).clearOrder();
      }
    } catch (e) {
      print('DEBUG ORDER PAGE: Error al limpiar estado en onWillPop: $e');
    }
    return true; // Permitir que la navegación continúe
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderStateProvider);
    final productState = ref.watch(productStateProvider);

    final filteredProducts = productState.products.where((product) {
      if (_searchQuery.isEmpty) return true;
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.borderColor, height: 1),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pedido - Mesa ${widget.table.number}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
            if (orderState.currentOrder != null)
              Text(
                'Orden #${orderState.currentOrder!.id}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: orderState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Row(
              children: [
                // Productos disponibles (lado izquierdo)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Barra de búsqueda
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        color: AppTheme.surfaceColor,
                        child: TextField(
                          controller: _searchController,
                          enabled: !orderState.isConfirmed,
                          decoration: InputDecoration(
                            hintText: 'Buscar productos...',
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                            filled: true,
                            fillColor: AppTheme.backgroundColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      
                      // Lista de productos (deshabilitada si ya está confirmado)
                      Expanded(
                        child: orderState.isConfirmed
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_outline, size: 48, color: AppTheme.textDisabled),
                                    SizedBox(height: 8),
                                    Text(
                                      'Pedido confirmado',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'No se pueden agregar más productos',
                                      style: TextStyle(
                                        color: AppTheme.textDisabled,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.2,
                                  crossAxisSpacing: AppTheme.spacingSmall,
                                  mainAxisSpacing: AppTheme.spacingSmall,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return _buildProductCard(product);
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                // Resumen del pedido (lado derecho)
                Container(
                  width: 350,
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      left: BorderSide(color: AppTheme.borderColor, width: 1),
                    ),
                  ),
                  child: _buildOrderSummary(orderState),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildProductCard(product) {
    final isAvailable = product.isAvailable;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.5,
      child: InkWell(
        onTap: isAvailable ? () => _addProduct(product) : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: isAvailable ? AppTheme.borderColor : AppTheme.textDisabled,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fastfood, size: 32, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isAvailable) ...[
                const SizedBox(height: 2),
                const Text(
                  'No disponible',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(product.salePrice),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(OrderState orderState) {
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
              Icon(Icons.shopping_cart, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Resumen del Pedido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Items (mostrar temporales si no está confirmado, o guardados si está confirmado)
        Expanded(
          child: () {
            final itemsToShow = orderState.isConfirmed 
                ? orderState.items 
                : orderState.temporaryItems;
            
            return itemsToShow.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 48, color: AppTheme.textDisabled),
                        SizedBox(height: 8),
                        Text(
                          'No hay items en el pedido',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                    itemCount: itemsToShow.length,
                    itemBuilder: (context, index) {
                      final item = itemsToShow[index];
                      return _buildOrderItem(item, canDelete: !orderState.isConfirmed);
                    },
                  );
          }(),
        ),

        // Campo de notas/observaciones
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.borderColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.note_alt, color: AppTheme.primaryColor, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Notas u Observaciones',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                enabled: !orderState.isConfirmed,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ej: Sin cebolla, picante, alergias...',
                  hintStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  contentPadding: const EdgeInsets.all(10),
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
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
                onChanged: (value) {
                  // Actualizar las notas en el estado cuando el usuario escribe
                  if (orderState.currentOrder != null) {
                    ref.read(orderStateProvider.notifier).updateNotes(
                          value.isEmpty ? null : value,
                        );
                  }
                },
              ),
            ],
          ),
        ),

        // Totales
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.borderColor)),
          ),
          child: Column(
            children: [
              _buildTotalRow('Subtotal:', orderState.subtotal),
              const SizedBox(height: 4),
              _buildTotalRow('Imp. Consumo:', orderState.tax),
              const Divider(height: 16, color: AppTheme.borderColor),
              _buildTotalRow('Total:', orderState.total, isBold: true),
              
              // Botón "Preparar Pedido" solo si no está confirmado
              if (!orderState.isConfirmed) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: orderState.temporaryItems.isEmpty ? null : _confirmOrder,
                    icon: const Icon(Icons.restaurant, size: 18),
                    label: const Text('Preparar Pedido'),
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
              ],
              
              // Indicador de pedido confirmado
              if (orderState.isConfirmed) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successColor, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Pedido en Preparación',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Botón para finalizar pedido y proceder al pago
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _proceedToPayment(),
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('Finalizar y Proceder al Pago'),
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
                const SizedBox(height: 8),
                
                // Botón para cancelar pedido
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelOrderDialog(),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancelar Pedido'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(item, {bool canDelete = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      padding: const EdgeInsets.all(AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
                '${item.quantity}x',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${CurrencyFormatter.format(item.unitPrice)} c/u',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item.subtotal),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (canDelete) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (!mounted) return;
                ref.read(orderStateProvider.notifier).removeTemporaryItem(item.productId);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppTheme.errorColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            color: isBold ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

