import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password, String companyCode);
  Future<User?> getCurrentUser();
  bool isLoggedIn();
  Future<bool> logout();
}
