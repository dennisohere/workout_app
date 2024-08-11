import 'package:firebase_auth/firebase_auth.dart';
import 'package:gainz/domain/entities/auth_user/auth_user.dart';
import 'package:gainz/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class FirebaseAuthRepository implements AuthRepository {
  AuthUser? _authUser;

  @override
  Future<AuthUser> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);

    return (await loadAuthUser())!;
  }

  @override
  Future<AuthUser?> loadAuthUser() async {
    final fbUser = FirebaseAuth.instance.currentUser;

    if (fbUser == null) return null;

    _authUser = AuthUser(
      id: fbUser.uid,
      displayName: fbUser.displayName!,
      email: fbUser.email,
      phoneNumber: fbUser.phoneNumber,
    );

    return _authUser;
  }

  @override
  bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  AuthUser? currentUser() {
    return _authUser;
  }

  @override
  Future logout() async {
    await FirebaseAuth.instance.signOut();
    _authUser = null;
  }
}
