import 'package:flutter/material.dart';

class AestheticStudentLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  const AestheticStudentLoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.isDark,
    required this.onDarkChanged,
  });

  @override
  State<AestheticStudentLoginScreen> createState() => _AestheticStudentLoginScreenState();
}

class _AestheticStudentLoginScreenState extends State<AestheticStudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController(text: '244107020121');
  final _passwordController = TextEditingController(text: 'mahasiswa2026');

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulasi autentikasi akademik
      await Future.delayed(const Duration(milliseconds: 750));
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onLoginSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = widget.isDark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Dark/Light Theme Toggle
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Semantics(
              label: isDark ? 'Beralih ke mode terang' : 'Beralih ke mode gelap',
              button: true,
              child: IconButton.filledTonal(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () => widget.onDarkChanged(!isDark),
                tooltip: 'Ganti Tema',
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E1B4B),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFFEEF2FF),
                    const Color(0xFFE0E7FF),
                    const Color(0xFFF8FAFC),
                  ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _buildGlassmorphicCard(context, theme, colorScheme, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ]
              : [
                  Colors.white.withValues(alpha: 0.85),
                  Colors.white.withValues(alpha: 0.65),
                ],
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Aesthetic Header Logo
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Portal Title
            Text(
              'Portal Akademik Mahasiswa',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Masuk untuk mengakses KRS, Transkrip & Jadwal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // NIM Field (Khusus Mahasiswa)
            Semantics(
              label: 'Input Nomor Induk Mahasiswa NIM',
              child: TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nomor Induk Mahasiswa (NIM)',
                  hintText: 'Contoh: 244107020121',
                  prefixIcon: const Icon(Icons.badge_rounded),
                  filled: true,
                  fillColor: isDark
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : colorScheme.surface.withValues(alpha: 0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }
                  if (val.trim().length < 6) {
                    return 'NIM minimal 6 digit angka';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            Semantics(
              label: 'Input Kata Sandi Akun Mahasiswa',
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Portal',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  filled: true,
                  fillColor: isDark
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : colorScheme.surface.withValues(alpha: 0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    tooltip: _obscurePassword ? 'Tampilkan sandi' : 'Sembunyikan sandi',
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Kata sandi wajib diisi';
                  }
                  if (val.trim().length < 6) {
                    return 'Kata sandi minimal 6 karakter';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (v) => setState(() => _rememberMe = v ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Ingat saya', style: theme.textTheme.bodySmall),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Silakan hubungi Helpdesk IT Kampus untuk reset PIN/Sandi.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Lupa Sandi?'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            FilledButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masuk ke Dashboard',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // Divider & SSO Mahasiswa
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'atau masuk via',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            // SSO / Biometric Button
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Autentikasi SSO Mahasiswa Berhasil!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                widget.onLoginSuccess();
              },
              icon: const Icon(Icons.fingerprint_rounded, size: 22),
              label: const Text('Login Cepat Biometrik / SSO'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
