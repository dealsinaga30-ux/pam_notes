import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submitEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.length < 6) {
      _showMessage('Masukkan email yang valid dan password minimal 6 karakter.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isRegisterMode) {
        await _authService.signUpWithEmail(email, password);
      } else {
        await _authService.signInWithEmail(email, password);
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Autentikasi gagal (${e.code}).');
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitGoogleAuth() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Login Google gagal (${e.code}).');
    } catch (e) {
      _showMessage('Login Google gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? 'Daftar Akun' : 'Login PAM Notes'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton(
                  onPressed: _submitEmailAuth,
                  child: Text(_isRegisterMode ? 'Daftar' : 'Masuk'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _isRegisterMode = !_isRegisterMode);
                  },
                  child: Text(
                    _isRegisterMode
                        ? 'Sudah punya akun? Masuk di sini'
                        : 'Belum punya akun? Daftar sekarang',
                  ),
                ),
                const Divider(height: 32),
                OutlinedButton.icon(
                  onPressed: _submitGoogleAuth,
                  icon: const Icon(Icons.login),
                  label: const Text('Masuk dengan Google'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
