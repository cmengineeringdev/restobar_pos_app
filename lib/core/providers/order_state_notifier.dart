import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/table_repository.dart';
import '../../domain/usecases/add_order_item.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/get_order_by_table.dart';
import '../../domain/usecases/get_order_items.dart';
import '../../domain/usecases/update_order_totals.dart';
import 'providers.dart';

/// Estado del pedido actual
class OrderState {
  final Order? currentOrder;
  final List<OrderItem> items; // Items guardados en DB (para ordenes confirmadas)
  final List<OrderItem> temporaryItems; // Items temporales (antes de confirmar)
  final bool isLoading;
  final String? error;
  final double subtotal;
  final double tax;
  final double tip; // Propina
  final double total;
  final bool isConfirmed; // Si el pedido ya fue confirmado

  const OrderState({
    this.currentOrder,
    this.items = const [],
    this.temporaryItems = const [],
    this.isLoading = false,
    this.error,
    this.subtotal = 0,
    this.tax = 0,
    this.tip = 0,
    this.total = 0,
    this.isConfirmed = false,
  });

  OrderState copyWith({
    Order? currentOrder,
    List<OrderItem>? items,
    List<OrderItem>? temporaryItems,
    bool? isLoading,
    String? error,
    double? subtotal,
    double? tax,
    double? tip,
    double? total,
    bool? isConfirmed,
    bool clearError = false,
    bool clearOrder = false,
  }) {
    return OrderState(
      currentOrder: clearOrder ? null : (currentOrder ?? this.currentOrder),
      items: items ?? this.items,
      temporaryItems: temporaryItems ?? this.temporaryItems,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      tip: tip ?? this.tip,
      total: total ?? this.total,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

/// Notificador de estado de pedidos
class OrderStateNotifier extends StateNotifier<OrderState> {
  final CreateOrder _createOrder;
  final AddOrderItem _addOrderItem;
  final GetOrderByTable _getOrderByTable;
  final GetOrderItems _getOrderItems;
  final UpdateOrderTotals _updateOrderTotals;
  final CancelOrder _cancelOrder;
  final OrderRepository _orderRepository;
  final TableRepository _tableRepository;

  OrderStateNotifier(
    this._createOrder,
    this._addOrderItem,
    this._getOrderByTable,
    this._getOrderItems,
    this._updateOrderTotals,
    this._cancelOrder,
    this._orderRepository,
    this._tableRepository,
  ) : super(const OrderState());

  /// Actualizar estado de forma segura solo si hay listeners
  void _safeSetState(OrderState newState) {
    if (mounted) {
      state = newState;
    }
  }

  /// Inicializar o cargar pedido para una mesa
  Future<void> initializeOrderForTable({
    required int tableId,
    required int workShiftId,
  }) async {
    _safeSetState(state.copyWith(isLoading: true, clearError: true));

    try {
      // Intentar obtener un pedido existente para la mesa
      var order = await _getOrderByTable(tableId);

      // Verificar si el pedido ya está confirmado (preparing, ready, etc.)
      if (order != null && (order.status == 'preparing' || order.status == 'ready' || order.status == 'delivered')) {
        print('DEBUG ORDER: Orden existente confirmada encontrada: ${order.id} - status: ${order.status}');
        print('DEBUG ORDER: Totales en DB - Subtotal: ${order.subtotal}, Tax: ${order.tax}, Total: ${order.total}');
        
        // Cargar los items de la orden desde DB
        final items = await _getOrderItems(order.id!);
        print('DEBUG ORDER: ${items.length} items cargados desde DB');

        // Calcular totales desde los items
        final subtotal = _calculateSubtotal(items);
        final tax = _calculateTax(items); // Ahora recibe items en vez de subtotal
        final tip = order.tip; // Mantener la propina guardada en DB
        final total = subtotal + tax + tip;

        print('DEBUG ORDER: Totales calculados - Subtotal: $subtotal, Tax: $tax, Tip: $tip, Total: $total');

        // Si los totales en DB están desactualizados, actualizarlos
        if (order.total != total) {
          print('DEBUG ORDER: Actualizando totales desactualizados en DB');
          await _updateOrderTotals(
            orderId: order.id!,
            subtotal: subtotal,
            tax: tax,
            tip: tip,
            total: total,
          );
        }

        _safeSetState(state.copyWith(
          currentOrder: order.copyWith(subtotal: subtotal, tax: tax, tip: tip, total: total),
          items: items,
          temporaryItems: [],
          subtotal: subtotal,
          tax: tax,
          tip: tip,
          total: total,
          isConfirmed: true,
          isLoading: false,
          clearError: true,
        ));
      } else {
        // No hay orden confirmada, trabajar con items temporales
        print('DEBUG ORDER: No hay orden confirmada, iniciando con items temporales');

        _safeSetState(state.copyWith(
          currentOrder: null,
          items: [],
          temporaryItems: [],
          subtotal: 0,
          tax: 0,
          tip: 0,
          total: 0,
          isConfirmed: false,
          isLoading: false,
          clearError: true,
        ));
      }
    } catch (e) {
      print('DEBUG ORDER: Error al inicializar orden: $e');
      _safeSetState(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      rethrow;
    }
  }

  /// Agregar producto al pedido temporal (no guarda en DB hasta confirmar)
  void addProduct({
    required int productId,
    required String productName,
    required double unitPrice,
    double? taxRate, // Tax rate percentage from product (null = no tax)
    int quantity = 1,
  }) {
    if (!mounted) return; // No actualizar si no hay listeners
    
    try {
      print('DEBUG ORDER: Agregando producto temporal $productName x$quantity');

      // Trabajar con items temporales (no DB)
      final currentTempItems = List<OrderItem>.from(state.temporaryItems);

      // Verificar si el producto ya existe en los items temporales
      final existingIndex = currentTempItems.indexWhere(
        (item) => item.productId == productId,
      );

      if (existingIndex != -1) {
        // Si existe, actualizar la cantidad
        final existingItem = currentTempItems[existingIndex];
        final newQuantity = existingItem.quantity + quantity;
        final newSubtotal = newQuantity * unitPrice;

        // Recalcular impuesto con la nueva cantidad
        final itemTaxRate = taxRate ?? 0.0; // Si es null, usar 0
        final newTaxAmount = newSubtotal * (itemTaxRate / 100);

        print('DEBUG ORDER: Producto ya existe, aumentando cantidad de ${existingItem.quantity} a $newQuantity');

        currentTempItems[existingIndex] = existingItem.copyWith(
          quantity: newQuantity,
          subtotal: newSubtotal,
          taxRate: itemTaxRate,
          taxAmount: newTaxAmount,
        );
      } else {
        // Si no existe, agregarlo como nuevo item temporal
        print('DEBUG ORDER: Producto nuevo, agregando a temporales');

        final itemSubtotal = quantity * unitPrice;
        final itemTaxRate = taxRate ?? 0.0; // Si es null, usar 0
        final itemTaxAmount = itemSubtotal * (itemTaxRate / 100);

        final newItem = OrderItem(
          productId: productId,
          orderId: 0, // No tiene orden aún
          productName: productName,
          quantity: quantity,
          unitPrice: unitPrice,
          subtotal: itemSubtotal,
          taxRate: itemTaxRate,
          taxAmount: itemTaxAmount,
          createdAt: DateTime.now(),
        );

        currentTempItems.add(newItem);
      }

      // Recalcular totales
      final subtotal = _calculateSubtotal(currentTempItems);
      final tax = _calculateTax(currentTempItems); // Ahora recibe items
      final tip = _calculateTip(subtotal); // Calcular propina automáticamente (10%)
      final total = subtotal + tax + tip;

      _safeSetState(state.copyWith(
        temporaryItems: currentTempItems,
        subtotal: subtotal,
        tax: tax,
        tip: tip,
        total: total,
        clearError: true,
      ));

      print('DEBUG ORDER: Producto agregado a temporales. Subtotal: \$$subtotal, Tax: \$$tax, Tip: \$$tip, Total: \$$total');
    } catch (e) {
      print('DEBUG ORDER: Error al agregar producto: $e');
      _safeSetState(state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      rethrow;
    }
  }

  /// Eliminar item temporal por productId
  void removeTemporaryItem(int productId) {
    if (!mounted) return;
    
    try {
      print('DEBUG ORDER: Eliminando item temporal con productId $productId');

      // Eliminar de items temporales
      final currentTempItems = List<OrderItem>.from(state.temporaryItems);
      currentTempItems.removeWhere((item) => item.productId == productId);

      // Recalcular totales
      final subtotal = _calculateSubtotal(currentTempItems);
      final tax = _calculateTax(currentTempItems); // Ahora recibe items
      final tip = _calculateTip(subtotal); // Recalcular propina automáticamente
      final total = subtotal + tax + tip;

      _safeSetState(state.copyWith(
        temporaryItems: currentTempItems,
        subtotal: subtotal,
        tax: tax,
        tip: tip,
        total: total,
        clearError: true,
      ));

      print('DEBUG ORDER: Item temporal eliminado. Subtotal: \$$subtotal, Tax: \$$tax, Tip: \$$tip, Total: \$$total');
    } catch (e) {
      print('DEBUG ORDER: Error al eliminar item temporal: $e');
      _safeSetState(state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Confirmar pedido: guarda en DB y cambia estado de mesa a ocupado
  Future<void> confirmOrder({
    required int tableId,
    required int workShiftId,
    String? notes,
  }) async {
    if (state.temporaryItems.isEmpty) {
      state = state.copyWith(error: 'No hay items para confirmar');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      print('DEBUG ORDER: Confirmando pedido para mesa $tableId');

      // 1. Crear la orden en DB (inicialmente con status 'open')
      final order = await _createOrder(
        tableId: tableId,
        workShiftId: workShiftId,
      );
      
      print('DEBUG ORDER: Orden creada con ID: ${order.id}');
      
      // 2. Actualizar status a 'preparing'
      await _orderRepository.updateOrderStatus(
        orderId: order.id!,
        status: 'preparing',
      );
      
      // 3. Actualizar notas si existen
      if (notes != null) {
        await _orderRepository.updateOrderNotes(
          orderId: order.id!,
          notes: notes,
        );
      }

      print('DEBUG ORDER: Orden actualizada a status preparing');

      // 2. Guardar todos los items temporales en DB
      for (final item in state.temporaryItems) {
        await _addOrderItem(
          orderId: order.id!,
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        );
        print('DEBUG ORDER: Item guardado: ${item.productName} x${item.quantity}');
      }

      // 3. Actualizar totales en DB
      await _updateOrderTotals(
        orderId: order.id!,
        subtotal: state.subtotal,
        tax: state.tax,
        tip: state.tip,
        total: state.total,
      );

      // 4. Cambiar estado de la mesa a 'occupied'
      await _tableRepository.updateTableStatus(tableId, 'occupied');
      print('DEBUG ORDER: Mesa actualizada a estado ocupado');

      // 5. Cargar los items guardados desde DB
      final savedItems = await _getOrderItems(order.id!);

      // 6. Obtener la orden actualizada desde DB
      final confirmedOrder = await _orderRepository.getOrderByTable(tableId);
      print('DEBUG ORDER: Orden recuperada desde DB - Subtotal: ${confirmedOrder?.subtotal}, Tax: ${confirmedOrder?.tax}, Total: ${confirmedOrder?.total}');

      // 7. Actualizar estado local con los totales de la orden confirmada
      state = state.copyWith(
        currentOrder: confirmedOrder,
        items: savedItems,
        temporaryItems: [], // Limpiar items temporales
        subtotal: confirmedOrder?.subtotal ?? state.subtotal,
        tax: confirmedOrder?.tax ?? state.tax,
        tip: confirmedOrder?.tip ?? state.tip,
        total: confirmedOrder?.total ?? state.total,
        isConfirmed: true,
        isLoading: false,
        clearError: true,
      );

      print('DEBUG ORDER: Pedido confirmado exitosamente - Estado Total: ${state.total}');
    } catch (e) {
      print('DEBUG ORDER: Error al confirmar pedido: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Calcular subtotal
  double _calculateSubtotal(List<OrderItem> items) {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Calcular impuesto total sumando el impuesto de cada item
  /// (Cada item tiene su propio taxRate y taxAmount calculado)
  double _calculateTax(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  /// Calcular propina (10% del subtotal por defecto)
  double _calculateTip(double subtotal) {
    return subtotal * 0.10;
  }

  /// Actualizar propina manualmente
  void updateTip(double newTip) {
    if (!mounted) return;

    try {
      print('DEBUG ORDER: Actualizando propina a \$$newTip');

      // Recalcular el total con la nueva propina
      final total = state.subtotal + state.tax + newTip;

      _safeSetState(state.copyWith(
        tip: newTip,
        total: total,
        clearError: true,
      ));

      print('DEBUG ORDER: Propina actualizada. Nuevo total: \$$total');
    } catch (e) {
      print('DEBUG ORDER: Error al actualizar propina: $e');
      _safeSetState(state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Actualizar notas del pedido
  Future<void> updateNotes(String? notes) async {
    if (state.currentOrder == null) {
      state = state.copyWith(error: 'No hay pedido activo');
      return;
    }

    try {
      print('DEBUG ORDER: Actualizando notas del pedido');
      await _orderRepository.updateOrderNotes(
        orderId: state.currentOrder!.id!,
        notes: notes,
      );

      // Actualizar el estado local
      final updatedOrder = state.currentOrder!.copyWith(notes: notes);
      state = state.copyWith(
        currentOrder: updatedOrder,
        clearError: true,
      );

      print('DEBUG ORDER: Notas actualizadas');
    } catch (e) {
      print('DEBUG ORDER: Error al actualizar notas: $e');
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Cancelar pedido actual
  Future<void> cancelOrder() async {
    if (state.currentOrder == null) {
      state = state.copyWith(error: 'No hay pedido activo para cancelar');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      print('DEBUG ORDER: Cancelando pedido ${state.currentOrder!.id}');

      // Cancelar el pedido y liberar la mesa
      await _cancelOrder(
        orderId: state.currentOrder!.id!,
        tableId: state.currentOrder!.tableId,
      );

      print('DEBUG ORDER: Pedido cancelado exitosamente');

      // Limpiar el estado
      state = const OrderState();
    } catch (e) {
      print('DEBUG ORDER: Error al cancelar pedido: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Limpiar pedido actual
  void clearOrder() {
    if (mounted) {
      state = const OrderState();
    }
  }

  /// Limpiar error
  void clearError() {
    _safeSetState(state.copyWith(clearError: true));
  }
}

/// Provider del notificador de pedidos
final orderStateProvider =
    StateNotifierProvider<OrderStateNotifier, OrderState>((ref) {
  final createOrder = ref.watch(createOrderProvider);
  final addOrderItem = ref.watch(addOrderItemProvider);
  final getOrderByTable = ref.watch(getOrderByTableProvider);
  final getOrderItems = ref.watch(getOrderItemsProvider);
  final updateOrderTotals = ref.watch(updateOrderTotalsProvider);
  final cancelOrder = ref.watch(cancelOrderProvider);
  final orderRepository = ref.watch(orderRepositoryProvider);
  final tableRepository = ref.watch(tableRepositoryProvider);
  return OrderStateNotifier(
    createOrder,
    addOrderItem,
    getOrderByTable,
    getOrderItems,
    updateOrderTotals,
    cancelOrder,
    orderRepository,
    tableRepository,
  );
});

