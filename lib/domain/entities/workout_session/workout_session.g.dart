// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSessionEntityImpl _$$WorkoutSessionEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutSessionEntityImpl(
      repCount: (json['repCount'] as num).toInt(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      secondsElapsed: (json['secondsElapsed'] as num).toInt(),
    );

Map<String, dynamic> _$$WorkoutSessionEntityImplToJson(
        _$WorkoutSessionEntityImpl instance) =>
    <String, dynamic>{
      'repCount': instance.repCount,
      'startedAt': instance.startedAt.toIso8601String(),
      'secondsElapsed': instance.secondsElapsed,
    };
