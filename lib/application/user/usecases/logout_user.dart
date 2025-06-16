import '../../../domaine/repositories/userRepo.dart';

class LogoutUser {
  final UserRepository repository;

  LogoutUser(this.repository);

  Future<void> call() async {
    await repository.logout();
  }
}
