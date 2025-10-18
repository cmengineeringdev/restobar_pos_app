import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser({required this.repository});

  Future<User> call(
      String username, String password, String companyCode) async {
    if (username.isEmpty || password.isEmpty || companyCode.isEmpty) {
      throw Exception('Username, password and company code are required');
    }

    return await repository.login(username, password, companyCode);
  }
}
