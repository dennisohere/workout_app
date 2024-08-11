
import 'package:gainz/domain/repositories/auth_repository.dart';

class AuthUseCases {

  final AuthRepository authRepository;

  AuthUseCases(this.authRepository);

  Future loginWithGoogle() async {
    return await authRepository.signInWithGoogle();
  }

  Future logout() async {
    return await authRepository.logout();
  }

}