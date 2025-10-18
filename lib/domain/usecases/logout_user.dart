import '../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository repository;

  LogoutUser({required this.repository});

  Future<bool> call() async {
    return await repository.logout();
  }
}
