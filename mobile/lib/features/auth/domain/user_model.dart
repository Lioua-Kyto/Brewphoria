import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firebaseUid,
    required String email,
    required String displayName,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    @Default('USER') String role,
    required DateTime createdAt,
  }) = _UserModel;

  const UserModel._();

  /// A friendly name derived from the email local-part when no real name is
  /// available (so greetings never show a raw email address).
  String get _fallbackName {
    final n = displayName.trim();
    if (n.isNotEmpty && !n.contains('@')) return n;
    final local = email.split('@').first;
    final cleaned = local.replaceAll(RegExp(r'[._\-+0-9]+'), ' ').trim();
    if (cleaned.isEmpty) return 'there';
    return cleaned
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// First name for greetings ("Good morning, Maya").
  String get greetingName {
    final f = (firstName ?? '').trim();
    if (f.isNotEmpty) return f;
    return _fallbackName.split(' ').first;
  }

  /// Full name for the profile header.
  String get fullName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isNotEmpty || l.isNotEmpty) {
      return [f, l].where((s) => s.isNotEmpty).join(' ');
    }
    return _fallbackName;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

@freezed
class LoyaltySummary with _$LoyaltySummary {
  const factory LoyaltySummary({
    required int currentPoints,
    required int lifetimePoints,
    required String tier,
  }) = _LoyaltySummary;

  factory LoyaltySummary.fromJson(Map<String, dynamic> json) => _$LoyaltySummaryFromJson(json);
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required UserModel user,
    required LoyaltySummary loyaltySummary,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
}
