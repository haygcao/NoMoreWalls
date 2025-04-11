import 'user_interface.dart';

/// Interface defining the authentication and authorization functionality
abstract class AuthInterface {
  /// Current authenticated user
  UserInterface? get currentUser;

  /// Whether a user is currently authenticated
  bool get isAuthenticated;

  /// Current access token
  String? get accessToken;

  /// Current refresh token
  String? get refreshToken;

  /// Token expiration timestamp
  DateTime? get tokenExpiration;

  /// Sign in with email and password
  Future<UserInterface> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign in with OAuth provider
  Future<UserInterface> signInWithOAuth(String provider);

  /// Sign out the current user
  Future<void> signOut();

  /// Refresh the access token
  Future<void> refreshAccessToken();

  /// Register a new user with email and password
  Future<UserInterface> register({
    required String email,
    required String password,
    required String displayName,
  });

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Verify email address
  Future<void> verifyEmail(String code);

  /// Delete the current user's account
  Future<void> deleteAccount(String password);

  /// Listen to authentication state changes
  Stream<UserInterface?> get onAuthStateChanged;

  /// Initialize the authentication system
  Future<void> initialize();
}
