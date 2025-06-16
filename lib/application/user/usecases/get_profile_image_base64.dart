import '../../../domaine/repositories/userRepo.dart';

class GetProfileImageBase64 {
  final UserRepository repository;

  GetProfileImageBase64(this.repository);

  Future<String?> call() async {
    return await repository.getProfileImageAsBase64();
  }
}
