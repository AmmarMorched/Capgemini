import '../../../domaine/entities/User.dart';
import '../../../domaine/repositories/userRepo.dart';


class SignupUser {
  final UserRepository repository;

  SignupUser(this.repository);

  Future<bool> call(Users user) {
    return repository.signup(user);
  }
}