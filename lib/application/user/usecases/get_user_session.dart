import 'package:capgemini/domaine/entities/User.dart';

import '../../../domaine/repositories/userRepo.dart';

class GetUserSession {
  final UserRepository repository;

  GetUserSession(this.repository);

  Future<Users?> call() async {
    return await repository.getCurrentUser();
  }
}
