
import '../entities/workout_session/workout_session.dart';
import '../repositories/workout_session_repository.dart';

class WorkoutUseCases {
  final WorkoutSessionRepository _repository;

  WorkoutUseCases(WorkoutSessionRepository repository) : _repository = repository;

  saveWorkout(WorkoutSessionEntity workoutSession){
    return _repository.saveWorkout(workoutSession);
  }

  Future<List<WorkoutSessionEntity>> loadWorkouts() async {
    return await _repository.loadWorkouts();
  }

  Future deleteWorkout(WorkoutSessionEntity workoutSessionEntity) async {
    await _repository.deleteWorkout(workoutSessionEntity.id!);
  }
}