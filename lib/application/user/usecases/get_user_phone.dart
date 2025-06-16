import '../../../domaine/repositories/userRepo.dart';

class GetUserPhone {
  final UserRepository repository;

  GetUserPhone(this.repository);

  Future<String?> call() async {
    return await repository.getCurrentUserPhone();
  }
}
