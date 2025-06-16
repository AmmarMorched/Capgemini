
import '../../../domaine/repositories/userRepo.dart';

class GetUserEmail {
  final UserRepository repository;

  GetUserEmail(this.repository);

  Future<String?> call() async {
    return await repository.getCurrentUserEmail();
  }
}
