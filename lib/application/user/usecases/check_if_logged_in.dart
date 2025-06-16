import '../../../domaine/repositories/userRepo.dart';

class CheckIfLoggedIn {
  final UserRepository repository;

  CheckIfLoggedIn(this.repository);

  Future<bool> call() async {
    return await repository.checkIfLoggedIn();
  }
}
