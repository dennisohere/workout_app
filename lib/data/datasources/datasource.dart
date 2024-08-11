

import 'package:gainz/domain/entities/workout_session/workout_session.dart';

abstract class Datasource {

  Future<List<WorkoutSessionEntity>> loadWorkouts();

  Future<void> saveWorkout(WorkoutSessionEntity workoutSession);

}