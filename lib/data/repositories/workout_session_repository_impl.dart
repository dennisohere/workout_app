
import 'package:gainz/data/datasources/datasource.dart';
import 'package:gainz/domain/entities/workout_session/workout_session.dart';
import 'package:gainz/domain/repositories/workout_session_repository.dart';
import 'package:logger/logger.dart';

class WorkoutSessionRepositoryImpl implements WorkoutSessionRepository {

  final Datasource db;

  WorkoutSessionRepositoryImpl(this.db);

  @override
  Future<void> saveWorkout(WorkoutSessionEntity workoutSession) async {
    await db.saveWorkout(workoutSession);
  }

  @override
  Future<List<WorkoutSessionEntity>> loadWorkouts() async {
    return await db.loadWorkouts();
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await db.deleteWorkout(id);
  }



}