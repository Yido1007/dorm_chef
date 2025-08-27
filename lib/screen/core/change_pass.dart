import 'dart:async';
import 'package:dorm_chef/service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obCur = true, _obNew = true, _obCon = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _isMounted => mounted;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final hasPasswordProvider =
        user?.providerData.any((p) => p.providerId == 'password') ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Güncelle'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                hasPasswordProvider
                    ? _buildPasswordForm(context, user!)
                    : _buildProviderInfo(context, user),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordForm(BuildContext context, User user) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _currentCtrl,
            obscureText: _obCur,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Mevcut Şifre',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obCur = !_obCur),
                icon: Icon(_obCur ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator:
                (v) => (v == null || v.isEmpty) ? 'Mevcut şifre gerekli' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _newCtrl,
            obscureText: _obNew,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Yeni Şifre',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obNew = !_obNew),
                icon: Icon(_obNew ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: (v) {
              final s = v ?? '';
              if (s.isEmpty) return 'Yeni şifre gerekli';
              if (s.length < 8) return 'En az 8 karakter';
              if (s == _currentCtrl.text) {
                return 'Yeni şifre mevcut şifreyle aynı olamaz';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obCon,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Yeni Şifre (Tekrar)',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obCon = !_obCon),
                icon: Icon(_obCon ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Yeni şifreyi tekrar girin';
              if (v != _newCtrl.text) return 'Şifreler eşleşmiyor';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : () => _changePassword(user),
              child:
                  _loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Şifreyi Güncelle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo(BuildContext context, User? user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.info_outline),
        const SizedBox(height: 12),
        const Text(
          'Bu hesap e-posta/şifre ile değil (ör. Google) ile giriş yapıyor.\n'
          'Şifre güncellemek için önce hesaba şifre eklemelisiniz.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed:
                user?.email == null
                    ? null
                    : () async {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: user!.email!.trim(),
                        );
                        if (_isMounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'E-posta gönderildi (varsa şifre oluşturabilirsiniz).',
                              ),
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        final msg = _mapAuthError(e);
                        if (_isMounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      }
                    },
            child: const Text('E-posta ile şifre oluştur / sıfırla'),
          ),
        ),
      ],
    );
  }

  Future<void> _changePassword(User user) async {
    if (!_formKey.currentState!.validate()) return;
    final email = user.email;
    if (email == null || email.isEmpty) {
      _showSnack('E-posta bulunamadı.');
      return;
    }

    setState(() => _loading = true);

    try {
      // 1) Re-auth (mevcut şifreyle)
      final cred = EmailAuthProvider.credential(
        email: email.trim(),
        password: _currentCtrl.text,
      );
      await user
          .reauthenticateWithCredential(cred)
          .timeout(const Duration(seconds: 8));
      await user
          .updatePassword(_newCtrl.text)
          .timeout(const Duration(seconds: 8));
      try {
        await AuthService().signOut();
      } catch (_) {
        await FirebaseAuth.instance.signOut();
      }

      if (!_isMounted) return;
      setState(() => _loading = false);
      Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifre güncellendi. Lütfen tekrar giriş yapın.'),
        ),
      );
    } on TimeoutException {
      if (_isMounted) {
        setState(() => _loading = false);
        _showSnack(
          'İşlem zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (_isMounted) {
        setState(() => _loading = false);
        _showSnack(_mapAuthError(e));
      }
    } catch (e) {
      if (_isMounted) {
        setState(() => _loading = false);
        _showSnack('Beklenmeyen hata: $e');
      }
    }
  }

  void _showSnack(String msg) {
    if (!_isMounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Mevcut şifre yanlış.';
      case 'requires-recent-login':
        return 'Güvenlik nedeniyle lütfen tekrar giriş yapın.';
      case 'weak-password':
        return 'Yeni şifre çok zayıf.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Bir süre sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'Ağ hatası. Bağlantınızı kontrol edin.';
      default:
        return 'Hata: ${e.code}';
    }
  }
}
