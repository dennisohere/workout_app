

import 'package:gainz/domain/entities/auth_user/auth_user.dart';

abstract class AuthRepository {

  AuthUser? currentUser();

  bool isAuthenticated();

  Future<AuthUser?> loadAuthUser();

  Future<AuthUser> signInWithGoogle();

  Future logout();
}