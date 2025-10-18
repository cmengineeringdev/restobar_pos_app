import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser({required this.repository});

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}
