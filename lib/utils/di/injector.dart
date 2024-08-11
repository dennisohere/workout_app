import 'package:gainz/data/datasources/datasource.dart';
import 'package:gainz/data/datasources/firebase_datasource.dart';
import 'package:gainz/data/repositories/firebase_auth_repository.dart';
import 'package:gainz/data/repositories/workout_session_repository_impl.dart';
import 'package:gainz/domain/repositories/auth_repository.dart';
import 'package:gainz/domain/repositories/workout_session_repository.dart';
import 'package:kiwi/kiwi.dart';

import '../router/router.dart';

abstract class Injector {
  static late KiwiContainer container;

  static setup() async {
    container = KiwiContainer();


    container.registerSingleton<Datasource>((c) => FirebaseDatasource());

    container.registerSingleton<AuthRepository>((c) => FirebaseAuthRepository());
    container.registerSingleton<AppRouter>((c) => AppRouter());

    container.registerFactory<WorkoutSessionRepository>((c) => WorkoutSessionRepositoryImpl(db));

    await container.resolve<AuthRepository>().loadAuthUser();
  }

  static final resolve = container.resolve;
  static final router = resolve<AppRouter>();
  static final db = resolve<Datasource>();
}