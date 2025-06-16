
import '../../../domaine/repositories/userRepo.dart';

class GetUserName {
  final UserRepository repository;

  GetUserName(this.repository);

  Future<String?> call() async {
    return await repository.getCurrentUserName();
  }
}
