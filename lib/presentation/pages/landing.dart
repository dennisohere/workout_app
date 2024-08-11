import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gainz/domain/repositories/auth_repository.dart';
import 'package:gainz/domain/usecases/auth.dart';
import 'package:gainz/utils/di/injector.dart';

import '../../utils/router/router.gr.dart';

@RoutePage()
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late final AuthRepository authRepository;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authRepository = Injector.resolve<AuthRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () {
                  context.pushRoute(const WorkoutRoute());
                },
                child: const Text('Start workout!'),
              ),
              FilledButton(
                onPressed: () async {
                  await AuthUseCases(authRepository).loginWithGoogle();
                  context.replaceRoute(const HomeRoute());
                },
                child: const Text('Sign in with Google'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
