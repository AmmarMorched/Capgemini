import '../../../domaine/repositories/userRepo.dart';

class SaveProfileImageBase64 {
  final UserRepository repository;

  SaveProfileImageBase64(this.repository);

  Future<void> call(String base64Image) async {
    return await repository.saveProfileImageAsBase64(base64Image);
  }
}
