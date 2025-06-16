import '../../../domaine/entities/User.dart';
import '../../../domaine/repositories/userRepo.dart';


class LoginUser {
  final UserRepository repository;
  LoginUser(this.repository);

  Future<bool> call(String email, String password) async {
    return await repository.login(email, password);
  }
}