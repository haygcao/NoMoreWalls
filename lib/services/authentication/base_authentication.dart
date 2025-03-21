abstract class MusicAuthenticationState {
  final String accessToken;
  final DateTime expiration;
  final bool isAnonymous;
  final Map<String, dynamic> credentials;

  const MusicAuthenticationState({
    required this.accessToken,
    required this.expiration,
    required this.isAnonymous,
    required this.credentials,
  });

  bool get isExpired => DateTime.now().isAfter(expiration);
}

abstract class MusicAuthenticationService {
  Future<MusicAuthenticationState?> getCurrentAuth();  // 添加这个方法
  Future<void> login(Map<String, String> credentials);
  Future<void> logout();
  Future<void> refresh();
  Future<bool> validate();
}