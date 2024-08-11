
import '../entities/workout_session/workout_session.dart';

abstract class WorkoutSessionRepository {

  Future<void> saveWorkout(WorkoutSessionEntity workoutSession);

  Future<List<WorkoutSessionEntity>> loadWorkouts();


}