// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutSessionEntity _$WorkoutSessionEntityFromJson(Map<String, dynamic> json) {
  return _WorkoutSessionEntity.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSessionEntity {
  int get repCount => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  int get secondsElapsed => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutSessionEntityCopyWith<WorkoutSessionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSessionEntityCopyWith<$Res> {
  factory $WorkoutSessionEntityCopyWith(WorkoutSessionEntity value,
          $Res Function(WorkoutSessionEntity) then) =
      _$WorkoutSessionEntityCopyWithImpl<$Res, WorkoutSessionEntity>;
  @useResult
  $Res call({int repCount, DateTime startedAt, int secondsElapsed, String? id});
}

/// @nodoc
class _$WorkoutSessionEntityCopyWithImpl<$Res,
        $Val extends WorkoutSessionEntity>
    implements $WorkoutSessionEntityCopyWith<$Res> {
  _$WorkoutSessionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repCount = null,
    Object? startedAt = null,
    Object? secondsElapsed = null,
    Object? id = freezed,
  }) {
    return _then(_value.copyWith(
      repCount: null == repCount
          ? _value.repCount
          : repCount // ignore: cast_nullable_to_non_nullable
              as int,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      secondsElapsed: null == secondsElapsed
          ? _value.secondsElapsed
          : secondsElapsed // ignore: cast_nullable_to_non_nullable
              as int,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSessionEntityImplCopyWith<$Res>
    implements $WorkoutSessionEntityCopyWith<$Res> {
  factory _$$WorkoutSessionEntityImplCopyWith(_$WorkoutSessionEntityImpl value,
          $Res Function(_$WorkoutSessionEntityImpl) then) =
      __$$WorkoutSessionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int repCount, DateTime startedAt, int secondsElapsed, String? id});
}

/// @nodoc
class __$$WorkoutSessionEntityImplCopyWithImpl<$Res>
    extends _$WorkoutSessionEntityCopyWithImpl<$Res, _$WorkoutSessionEntityImpl>
    implements _$$WorkoutSessionEntityImplCopyWith<$Res> {
  __$$WorkoutSessionEntityImplCopyWithImpl(_$WorkoutSessionEntityImpl _value,
      $Res Function(_$WorkoutSessionEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repCount = null,
    Object? startedAt = null,
    Object? secondsElapsed = null,
    Object? id = freezed,
  }) {
    return _then(_$WorkoutSessionEntityImpl(
      repCount: null == repCount
          ? _value.repCount
          : repCount // ignore: cast_nullable_to_non_nullable
              as int,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      secondsElapsed: null == secondsElapsed
          ? _value.secondsElapsed
          : secondsElapsed // ignore: cast_nullable_to_non_nullable
              as int,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSessionEntityImpl extends _WorkoutSessionEntity {
  const _$WorkoutSessionEntityImpl(
      {required this.repCount,
      required this.startedAt,
      required this.secondsElapsed,
      this.id})
      : super._();

  factory _$WorkoutSessionEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSessionEntityImplFromJson(json);

  @override
  final int repCount;
  @override
  final DateTime startedAt;
  @override
  final int secondsElapsed;
  @override
  final String? id;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSessionEntityImplCopyWith<_$WorkoutSessionEntityImpl>
      get copyWith =>
          __$$WorkoutSessionEntityImplCopyWithImpl<_$WorkoutSessionEntityImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSessionEntityImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSessionEntity extends WorkoutSessionEntity {
  const factory _WorkoutSessionEntity(
      {required final int repCount,
      required final DateTime startedAt,
      required final int secondsElapsed,
      final String? id}) = _$WorkoutSessionEntityImpl;
  const _WorkoutSessionEntity._() : super._();

  factory _WorkoutSessionEntity.fromJson(Map<String, dynamic> json) =
      _$WorkoutSessionEntityImpl.fromJson;

  @override
  int get repCount;
  @override
  DateTime get startedAt;
  @override
  int get secondsElapsed;
  @override
  String? get id;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutSessionEntityImplCopyWith<_$WorkoutSessionEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
