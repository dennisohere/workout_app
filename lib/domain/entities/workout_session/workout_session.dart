
import 'package:equatable/equatable.dart';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

@freezed
class WorkoutSessionEntity extends Equatable with _$WorkoutSessionEntity {
  const WorkoutSessionEntity._();

  const factory WorkoutSessionEntity({
    required int repCount,
    required DateTime startedAt,
    required int secondsElapsed,
    String? id,
  }) = _WorkoutSessionEntity;


  factory WorkoutSessionEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionEntityFromJson(json);


  @override
  List<Object?> get props => [repCount, startedAt, secondsElapsed];

}
