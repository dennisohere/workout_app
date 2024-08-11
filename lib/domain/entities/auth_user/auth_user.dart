
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String displayName,
    String? email,
    String? phoneNumber,
  }) = _AuthUser;



  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}