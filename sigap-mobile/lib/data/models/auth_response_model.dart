import 'user_model.dart';

/// Models the backend response for `/api/auth/login` and `/api/auth/me`.
class AuthResponseModel {
  final String status;
  final String message;
  final String? token;
  final String? tokenType;
  final String actor;
  final UserModel user;

  const AuthResponseModel({
    required this.status,
    required this.message,
    this.token,
    this.tokenType,
    required this.actor,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'success';
    final message = json['message']?.toString() ?? '';

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final token = data['token']?.toString();
    final tokenType = data['token_type']?.toString();
    final actor = data['actor']?.toString() ?? 'masyarakat';

    final userData = data['user'] as Map<String, dynamic>? ?? {};
    final user = UserModel.fromJson(userData, explicitActor: actor);

    return AuthResponseModel(
      status: status,
      message: message,
      token: token,
      tokenType: tokenType,
      actor: actor,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': {
        'token': token,
        'token_type': tokenType,
        'actor': actor,
        'user': user.toJson(),
      },
    };
  }
}
