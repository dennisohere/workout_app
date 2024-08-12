import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gainz/domain/entities/auth_user/auth_user.dart';
import 'package:gainz/domain/entities/data_loader/data_loader.dart';
import 'package:gainz/domain/repositories/auth_repository.dart';
import 'package:gainz/domain/repositories/workout_session_repository.dart';
import 'package:gainz/domain/usecases/auth.dart';
import 'package:gainz/domain/usecases/workout.dart';
import 'package:gainz/utils/di/injector.dart';
import 'package:gainz/utils/router/router.gr.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/workout_session/workout_session.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthRepository authRepository;
  late final AuthUser? authUser;
  DataLoader<List<WorkoutSessionEntity>> dataLoader =
      const DataLoader.initial();
  late final WorkoutUseCases workoutUseCases;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authRepository = Injector.resolve<AuthRepository>();
    authUser = authRepository.currentUser();
    workoutUseCases = WorkoutUseCases(Injector.resolve<WorkoutSessionRepository>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            authUser == null
                ? const SizedBox.shrink()
                : CircleAvatar(
                    child: Text(authUser!.displayName.characters.first),
                  ).padding(right: 10),
            const Text('My Workouts'),
          ],
        ),
        automaticallyImplyLeading: true,
        actions: [
          if (!authRepository.isAuthenticated())
            FilledButton(
                onPressed: () {
                  context.pushRoute(const LandingRoute());
                },
                child: const Text('Sign in')),
          if (authRepository.isAuthenticated())
            OutlinedButton(
                    onPressed: () async {
                      await AuthUseCases(authRepository).logout();
                      context.replaceRoute(const LandingRoute());
                    },
                    child: const Text('Sign out').textColor(Colors.white))
                .padding(right: 15)
        ],
      ),
      body: FutureBuilder(
        future: workoutUseCases.loadWorkouts(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            dataLoader = const DataLoader.loading();
          }
          if (snapshot.hasError) {
            dataLoader = DataLoader.error(message: snapshot.error.toString());
          }

          dataLoader = DataLoader<List<WorkoutSessionEntity>>.data(snapshot.data ?? []);

          return dataLoader.when(
            data: (data) {
              final records = data as List<WorkoutSessionEntity>;
              return ListView.builder(
                itemBuilder: (ctx, index) {
                  final record = records.elementAt(index);

                  return ListTile(
                    title: Text('${record.repCount} reps in ${record.secondsElapsed} sec').fontSize(17).bold(),
                    subtitle: Text(DateFormat.yMEd().format(record.startedAt)),
                    leading: const CircleAvatar(
                      child: Icon(Icons.accessibility_new, size: 30,),
                    ),
                    trailing: IconButton(onPressed: () async {
                      await workoutUseCases.deleteWorkout(record);
                      setState(() {});
                    }, icon: const Icon(Icons.delete, color: Colors.red,)),
                  );
                },
                itemCount: records.length,
              );
            },
            initial: () => const Center(
              child: Row(
                children: [
                  Icon(Icons.info),
                  Text('No workouts found. Start new session.')
                ],
              ),
            ),
            loading: () => const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Text('Loading workouts...')
                ],
              ),
            ),
            error: (error) => Center(
              child: Row(
                children: [
                  const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  Text('$error')
                ],
              ),
            ),
          ).padding(bottom: 50);
        },
      ),
      floatingActionButton: FilledButton.icon(
        onPressed: () {
          context.pushRoute(const WorkoutRoute());
        },
        label: const Text('New Session'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
