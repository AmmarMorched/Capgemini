import '../../../domaine/repositories/userRepo.dart';

class UpdateUserProfile {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  Future<void> call({required String name, required int phone}) async {
    await repository.updateUserProfile(name: name, phone: phone);
  }
}
