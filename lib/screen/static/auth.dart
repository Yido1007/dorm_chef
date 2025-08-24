import 'package:flutter/material.dart';
import '../../service/auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  final _auth = AuthService();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await _auth.signIn(email: _email.text, password: _pass.text);
      } else {
        await _auth.signUp(email: _email.text, password: _pass.text);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Giriş yap' : 'Kayıt ol')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (v) =>
                            (v == null || !v.contains('@'))
                                ? 'Geçerli e-posta girin'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pass,
                    decoration: const InputDecoration(
                      labelText: 'Şifre (min 6)',
                    ),
                    obscureText: true,
                    validator:
                        (v) =>
                            (v != null && v.length >= 6)
                                ? null
                                : 'En az 6 karakter',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Text(_isLogin ? 'Giriş' : 'Kayıt'),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _loading
                            ? null
                            : () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? 'Hesabın yok mu? Kayıt ol'
                          : 'Hesabın var mı? Giriş yap',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
