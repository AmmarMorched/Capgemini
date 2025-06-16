import '../../../domaine/repositories/userRepo.dart';


class SaveUserSession {
  final UserRepository repository;

  SaveUserSession(this.repository);

  Future<void> call(String username, String email) async {
    await repository.saveUserToLocalStorage(username, email);
  }
}
