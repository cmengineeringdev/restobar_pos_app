import '../../../core/services/storage_service.dart';
import '../../models/auth_models.dart';

abstract class AuthLocalDataSource {
  Future<bool> saveUser(UserModel user);
  UserModel? getUser();
  String? getAccessToken();
  bool isLoggedIn();
  Future<bool> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSourceImpl({required this.storageService});

  @override
  Future<bool> saveUser(UserModel user) async {
    return await storageService.saveUser(user);
  }

  @override
  UserModel? getUser() {
    return storageService.getUser();
  }

  @override
  String? getAccessToken() {
    return storageService.getAccessToken();
  }

  @override
  bool isLoggedIn() {
    return storageService.isLoggedIn();
  }

  @override
  Future<bool> logout() async {
    return await storageService.clearUserData();
  }
}
