// lib/services/session.dart
class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  String? token; // Firebase ID Token
  bool get isAuthenticated => token != null && token!.isNotEmpty;
}
