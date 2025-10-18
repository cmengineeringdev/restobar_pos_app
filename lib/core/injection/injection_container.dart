import 'package:http/http.dart' as http;
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/point_of_sale_local_datasource.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/point_of_sale_remote_datasource.dart';
import '../../data/datasources/remote/product_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/point_of_sale_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/point_of_sale_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/clear_point_of_sale.dart';
import '../../domain/usecases/get_points_of_sale.dart';
import '../../domain/usecases/get_selected_point_of_sale.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/select_point_of_sale.dart';
import '../../domain/usecases/sync_products.dart';
import '../database/database_service.dart';
import '../services/http_service.dart';
import '../services/storage_service.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();

  factory InjectionContainer() => _instance;

  InjectionContainer._internal();

  // Core
  late DatabaseService databaseService;
  late StorageService storageService;
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

  // Repositories
  late AuthRepository authRepository;
  late ProductRepository productRepository;
  late PointOfSaleRepository pointOfSaleRepository;

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

  /// Initialize all dependencies
  Future<void> init() async {
    // Core
    storageService = StorageService();
    await storageService.init();

    databaseService = DatabaseService();
    await databaseService.database; // Initialize database

    httpClient = http.Client();
    authenticatedHttpClient =
        AuthenticatedHttpClient(httpClient, storageService);

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
  }
}
