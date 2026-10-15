class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

class AuthRepository {
  // Titik integrasi Firebase Auth:
  // Dapat diganti dengan FirebaseAuth.instance.signInWithEmailAndPassword
  // atau GoogleSignIn saat backend Firebase Production diaktifkan.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid (min. 6 karakter).');
    }
    // Simulasi JWT: access token (umur pendek) + refresh token (umur panjang).
    final cleanEmail = email.trim().toLowerCase();
    return AuthSession(
      access: 'mock-access-for-$cleanEmail',
      refresh: 'mock-refresh-for-$cleanEmail',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token hilang atau kedaluwarsa.');
    }
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
