import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/point_of_sale.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/point_of_sale_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/table_repository.dart';
import '../../domain/repositories/work_shift_repository.dart';
import '../../domain/usecases/add_order_item.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/clear_point_of_sale.dart';
import '../../domain/usecases/close_work_shift.dart';
import '../../domain/usecases/complete_order.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/create_payment.dart';
import '../../domain/usecases/create_tables_for_point_of_sale.dart';
import '../../domain/usecases/get_active_work_shift.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_all_tables.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/get_order_by_table.dart';
import '../../domain/usecases/get_order_items.dart';
import '../../domain/usecases/get_payments_by_order.dart';
import '../../domain/usecases/get_points_of_sale.dart';
import '../../domain/usecases/get_selected_point_of_sale.dart';
import '../../domain/usecases/get_total_paid_for_order.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/open_work_shift.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/select_point_of_sale.dart';
import '../../domain/usecases/sync_products.dart';
import '../../domain/usecases/update_order_totals.dart';
import '../../domain/usecases/update_table_status.dart';
import '../injection/injection_container.dart';

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return InjectionContainer().authRepository;
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return InjectionContainer().productRepository;
});

final pointOfSaleRepositoryProvider = Provider<PointOfSaleRepository>((ref) {
  return InjectionContainer().pointOfSaleRepository;
});

final workShiftRepositoryProvider = Provider<WorkShiftRepository>((ref) {
  return InjectionContainer().workShiftRepository;
});

final tableRepositoryProvider = Provider<TableRepository>((ref) {
  return InjectionContainer().tableRepository;
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return InjectionContainer().orderRepository;
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return InjectionContainer().paymentRepository;
});

// ============================================================================
// USE CASE PROVIDERS - AUTH
// ============================================================================

final loginUserProvider = Provider<LoginUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUser(repository: repository);
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repository: repository);
});

final logoutUserProvider = Provider<LogoutUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUser(repository: repository);
});

// ============================================================================
// USE CASE PROVIDERS - PRODUCTS
// ============================================================================

final getAllProductsProvider = Provider<GetAllProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetAllProducts(repository: repository);
});

final searchProductsProvider = Provider<SearchProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SearchProducts(repository: repository);
});

final syncProductsProvider = Provider<SyncProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SyncProducts(repository: repository);
});

// ============================================================================
// USE CASE PROVIDERS - POINT OF SALE
// ============================================================================

final getPointsOfSaleProvider = Provider<GetPointsOfSale>((ref) {
  final repository = ref.watch(pointOfSaleRepositoryProvider);
  return GetPointsOfSale(repository: repository);
});

final selectPointOfSaleProvider = Provider<SelectPointOfSale>((ref) {
  final repository = ref.watch(pointOfSaleRepositoryProvider);
  return SelectPointOfSale(repository: repository);
});

final getSelectedPointOfSaleProvider = Provider<GetSelectedPointOfSale>((ref) {
  final repository = ref.watch(pointOfSaleRepositoryProvider);
  return GetSelectedPointOfSale(repository: repository);
});

final clearPointOfSaleProvider = Provider<ClearPointOfSale>((ref) {
  final repository = ref.watch(pointOfSaleRepositoryProvider);
  return ClearPointOfSale(repository: repository);
});

// ============================================================================
// USE CASE PROVIDERS - WORK SHIFT
// ============================================================================

final getActiveWorkShiftProvider = Provider<GetActiveWorkShift>((ref) {
  final repository = ref.watch(workShiftRepositoryProvider);
  return GetActiveWorkShift(repository);
});

final openWorkShiftProvider = Provider<OpenWorkShift>((ref) {
  final repository = ref.watch(workShiftRepositoryProvider);
  return OpenWorkShift(repository);
});

final closeWorkShiftProvider = Provider<CloseWorkShift>((ref) {
  final repository = ref.watch(workShiftRepositoryProvider);
  return CloseWorkShift(repository);
});

// ============================================================================
// USE CASE PROVIDERS - TABLES
// ============================================================================

final getAllTablesProvider = Provider<GetAllTables>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return GetAllTables(repository);
});

final updateTableStatusProvider = Provider<UpdateTableStatus>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return UpdateTableStatus(repository);
});

final createTablesForPointOfSaleProvider =
    Provider<CreateTablesForPointOfSale>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return CreateTablesForPointOfSale(repository);
});

// ============================================================================
// USE CASE PROVIDERS - ORDERS
// ============================================================================

final createOrderProvider = Provider<CreateOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CreateOrder(repository);
});

final addOrderItemProvider = Provider<AddOrderItem>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return AddOrderItem(repository);
});

final getOrderByTableProvider = Provider<GetOrderByTable>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderByTable(repository);
});

final getOrderItemsProvider = Provider<GetOrderItems>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderItems(repository);
});

final updateOrderTotalsProvider = Provider<UpdateOrderTotals>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return UpdateOrderTotals(repository);
});

final cancelOrderProvider = Provider<CancelOrder>((ref) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  final tableRepository = ref.watch(tableRepositoryProvider);
  return CancelOrder(
    orderRepository: orderRepository,
    tableRepository: tableRepository,
  );
});

final completeOrderProvider = Provider<CompleteOrder>((ref) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  final tableRepository = ref.watch(tableRepositoryProvider);
  return CompleteOrder(
    orderRepository: orderRepository,
    tableRepository: tableRepository,
  );
});

// ============================================================================
// USE CASE PROVIDERS - PAYMENTS
// ============================================================================

final createPaymentProvider = Provider<CreatePayment>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return CreatePayment(repository);
});

final getPaymentsByOrderProvider = Provider<GetPaymentsByOrder>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetPaymentsByOrder(repository);
});

final getTotalPaidForOrderProvider = Provider<GetTotalPaidForOrder>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetTotalPaidForOrder(repository);
});

// ============================================================================
// STATE PROVIDERS - DATA
// ============================================================================

/// Current authenticated user
final currentUserProvider = FutureProvider<User?>((ref) async {
  final getCurrentUser = ref.watch(getCurrentUserProvider);
  return await getCurrentUser();
});

/// Selected point of sale
final selectedPointOfSaleProvider = FutureProvider<PointOfSale?>((ref) async {
  final getSelectedPointOfSale = ref.watch(getSelectedPointOfSaleProvider);
  return await getSelectedPointOfSale();
});

/// All points of sale
final pointsOfSaleProvider = FutureProvider<List<PointOfSale>>((ref) async {
  final getPointsOfSale = ref.watch(getPointsOfSaleProvider);
  return await getPointsOfSale();
});

/// All products from local database
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final getAllProducts = ref.watch(getAllProductsProvider);
  return await getAllProducts();
});

