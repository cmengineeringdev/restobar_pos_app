import 'package:http/http.dart' as http;
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/order_local_datasource.dart';
import '../../data/datasources/local/payment_local_datasource.dart';
import '../../data/datasources/local/point_of_sale_local_datasource.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../../data/datasources/local/table_local_datasource.dart';
import '../../data/datasources/local/work_shift_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/point_of_sale_remote_datasource.dart';
import '../../data/datasources/remote/product_remote_datasource.dart';
import '../../data/datasources/remote/work_shift_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/point_of_sale_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/table_repository_impl.dart';
import '../../data/repositories/work_shift_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/point_of_sale_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/table_repository.dart';
import '../../domain/repositories/work_shift_repository.dart';
import '../../domain/usecases/add_order_item.dart';
import '../../domain/usecases/clear_point_of_sale.dart';
import '../../domain/usecases/close_work_shift.dart';
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
import '../database/database_service.dart';
import '../services/http_service.dart';
import '../services/storage_service.dart';
import '../services/session_manager.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();

  factory InjectionContainer() => _instance;

  InjectionContainer._internal();

  // Core
  late DatabaseService databaseService;
  late StorageService storageService;
  late SessionManager sessionManager;
  late http.Client httpClient;
  late AuthenticatedHttpClient authenticatedHttpClient;

  // Data sources - Auth
  late AuthLocalDataSource authLocalDataSource;
  late AuthRemoteDataSource authRemoteDataSource;

  // Data sources - Products
  late ProductLocalDataSource productLocalDataSource;
  late ProductRemoteDataSource productRemoteDataSource;

  // Data sources - Point of Sale
  late PointOfSaleLocalDataSource pointOfSaleLocalDataSource;
  late PointOfSaleRemoteDataSource pointOfSaleRemoteDataSource;

  // Data sources - Work Shift
  late WorkShiftLocalDataSource workShiftLocalDataSource;
  late WorkShiftRemoteDataSource workShiftRemoteDataSource;

  // Data sources - Tables
  late TableLocalDataSource tableLocalDataSource;

  // Data sources - Orders
  late OrderLocalDataSource orderLocalDataSource;

  // Data sources - Payments
  late PaymentLocalDataSource paymentLocalDataSource;

  // Repositories
  late AuthRepository authRepository;
  late ProductRepository productRepository;
  late PointOfSaleRepository pointOfSaleRepository;
  late WorkShiftRepository workShiftRepository;
  late TableRepository tableRepository;
  late OrderRepository orderRepository;
  late PaymentRepository paymentRepository;

  // Use cases - Auth
  late LoginUser loginUser;
  late GetCurrentUser getCurrentUser;
  late LogoutUser logoutUser;

  // Use cases - Products
  late GetAllProducts getAllProducts;
  late SearchProducts searchProducts;
  late SyncProducts syncProducts;

  // Use cases - Point of Sale
  late GetPointsOfSale getPointsOfSale;
  late SelectPointOfSale selectPointOfSale;
  late GetSelectedPointOfSale getSelectedPointOfSale;
  late ClearPointOfSale clearPointOfSale;

  // Use cases - Work Shift
  late GetActiveWorkShift getActiveWorkShift;
  late OpenWorkShift openWorkShift;
  late CloseWorkShift closeWorkShift;

  // Use cases - Tables
  late GetAllTables getAllTables;
  late UpdateTableStatus updateTableStatus;
  late CreateTablesForPointOfSale createTablesForPointOfSale;

  // Use cases - Orders
  late CreateOrder createOrder;
  late AddOrderItem addOrderItem;
  late GetOrderByTable getOrderByTable;
  late GetOrderItems getOrderItems;
  late UpdateOrderTotals updateOrderTotals;

  // Use cases - Payments
  late CreatePayment createPayment;
  late GetPaymentsByOrder getPaymentsByOrder;
  late GetTotalPaidForOrder getTotalPaidForOrder;

  /// Initialize all dependencies
  Future<void> init() async {
    // Core
    storageService = StorageService();
    await storageService.init();

    sessionManager = SessionManager();

    databaseService = DatabaseService();
    await databaseService.database; // Initialize database

    httpClient = http.Client();
    authenticatedHttpClient =
        AuthenticatedHttpClient(httpClient, storageService, sessionManager);

    // Data sources - Auth
    authLocalDataSource = AuthLocalDataSourceImpl(
      storageService: storageService,
    );

    authRemoteDataSource = AuthRemoteDataSourceImpl(
      httpClient: httpClient, // Use regular client for auth (no token yet)
    );

    // Data sources - Products
    productLocalDataSource = ProductLocalDataSourceImpl(
      databaseService: databaseService,
    );

    productRemoteDataSource = ProductRemoteDataSourceImpl(
      httpClient: authenticatedHttpClient, // Use authenticated client
    );

    // Data sources - Point of Sale
    pointOfSaleLocalDataSource = PointOfSaleLocalDataSourceImpl(
      databaseService: databaseService,
    );

    pointOfSaleRemoteDataSource = PointOfSaleRemoteDataSourceImpl(
      httpClient: authenticatedHttpClient, // Use authenticated client
    );

    // Data sources - Work Shift
    workShiftLocalDataSource = WorkShiftLocalDataSourceImpl(
      databaseService: databaseService,
    );

    workShiftRemoteDataSource = WorkShiftRemoteDataSourceImpl(
      httpClient: authenticatedHttpClient, // Use authenticated client
    );

    // Data sources - Tables
    tableLocalDataSource = TableLocalDataSourceImpl(
      databaseService: databaseService,
    );

    // Data sources - Orders
    orderLocalDataSource = OrderLocalDataSourceImpl(
      databaseService: databaseService,
    );

    // Data sources - Payments
    paymentLocalDataSource = PaymentLocalDataSourceImpl(
      databaseService: databaseService,
    );

    // Repositories
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

    productRepository = ProductRepositoryImpl(
      localDataSource: productLocalDataSource,
      remoteDataSource: productRemoteDataSource,
    );

    pointOfSaleRepository = PointOfSaleRepositoryImpl(
      remoteDataSource: pointOfSaleRemoteDataSource,
      localDataSource: pointOfSaleLocalDataSource,
    );

    workShiftRepository = WorkShiftRepositoryImpl(
      remoteDataSource: workShiftRemoteDataSource,
      localDataSource: workShiftLocalDataSource,
    );

    tableRepository = TableRepositoryImpl(
      localDataSource: tableLocalDataSource,
    );

    orderRepository = OrderRepositoryImpl(
      localDataSource: orderLocalDataSource,
    );

    paymentRepository = PaymentRepositoryImpl(
      localDataSource: paymentLocalDataSource,
    );

    // Use cases - Auth
    loginUser = LoginUser(repository: authRepository);
    getCurrentUser = GetCurrentUser(repository: authRepository);
    logoutUser = LogoutUser(repository: authRepository);

    // Use cases - Products
    getAllProducts = GetAllProducts(repository: productRepository);
    searchProducts = SearchProducts(repository: productRepository);
    syncProducts = SyncProducts(repository: productRepository);

    // Use cases - Point of Sale
    getPointsOfSale = GetPointsOfSale(repository: pointOfSaleRepository);
    selectPointOfSale = SelectPointOfSale(repository: pointOfSaleRepository);
    getSelectedPointOfSale =
        GetSelectedPointOfSale(repository: pointOfSaleRepository);
    clearPointOfSale = ClearPointOfSale(repository: pointOfSaleRepository);

    // Use cases - Work Shift
    getActiveWorkShift = GetActiveWorkShift(workShiftRepository);
    openWorkShift = OpenWorkShift(workShiftRepository);
    closeWorkShift = CloseWorkShift(workShiftRepository);

    // Use cases - Tables
    getAllTables = GetAllTables(tableRepository);
    updateTableStatus = UpdateTableStatus(tableRepository);
    createTablesForPointOfSale = CreateTablesForPointOfSale(tableRepository);

    // Use cases - Orders
    createOrder = CreateOrder(orderRepository);
    addOrderItem = AddOrderItem(orderRepository);
    getOrderByTable = GetOrderByTable(orderRepository);
    getOrderItems = GetOrderItems(orderRepository);
    updateOrderTotals = UpdateOrderTotals(orderRepository);

    // Use cases - Payments
    createPayment = CreatePayment(paymentRepository);
    getPaymentsByOrder = GetPaymentsByOrder(paymentRepository);
    getTotalPaidForOrder = GetTotalPaidForOrder(paymentRepository);
  }
}
