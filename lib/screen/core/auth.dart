import 'package:firebase_auth/firebase_auth.dart';
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
  final _name = TextEditingController();
  final _confirm = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _obPass = true;
  bool _obConfirm = true;

  final _auth = AuthService();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await _auth.signIn(email: _email.text.trim(), password: _pass.text);
      } else {
        await _auth.signUpWithName(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _pass.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.message ?? _mapAuthError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    String email = _email.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      final ctrl = TextEditingController(text: email);
      final ok = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Şifre sıfırlama'),
              content: TextField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta adresiniz',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('İptal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Gönder'),
                ),
              ],
            ),
      );
      if (ok != true) return;
      email = ctrl.text.trim();
    }

    if (!mounted) return;
    setState(() => _loading = true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Eğer bu e-posta kayıtlıysa, sıfırlama bağlantısı gönderildi.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-email' => 'Geçerli bir e-posta girin.',
        'missing-email' => 'E-posta adresi gerekli.',
        'too-many-requests' =>
          'Çok fazla deneme. Bir süre sonra tekrar deneyin.',
        _ => e.message ?? 'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
      };
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre Firebase politikasını karşılamıyor.';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı.';
      case 'invalid-email':
        return 'Geçersiz e-posta.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      default:
        return 'Hata: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Giriş yap' : 'Kayıt ol'),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Card(
                color: cs.surfaceContainerHighest,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: cs.primary.withOpacity(.12),
                            child: Icon(
                              _isLogin ? Icons.login : Icons.person_add,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isLogin
                                  ? 'Hoş geldin! Giriş yap'
                                  : 'Aramıza katıl! Kayıt ol',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _name,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'İsim',
                            hintText: 'Ad Soyad',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'İsim gerekli';
                            if (t.length < 2) return 'En az 2 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          hintText: 'mail@ornek.com',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator:
                            (v) =>
                                (v == null || !v.contains('@'))
                                    ? 'Geçerli e-posta girin'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pass,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obPass = !_obPass),
                            icon: Icon(
                              _obPass ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: _obPass,
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final s = v ?? '';
                          if (s.isEmpty) return 'Şifre gerekli';
                          return null;
                        },
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 10),
                        _PasswordStrengthBar(password: _pass.text),
                        const SizedBox(height: 8),
                        _PasswordRulesChecklist(password: _pass.text),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirm,
                          decoration: InputDecoration(
                            labelText: 'Şifre (Tekrar)',
                            prefixIcon: const Icon(Icons.check),
                            suffixIcon: IconButton(
                              onPressed:
                                  () =>
                                      setState(() => _obConfirm = !_obConfirm),
                              icon: Icon(
                                _obConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: _obConfirm,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Şifreyi tekrar girin';
                            }
                            if (v != _pass.text) return 'Şifreler eşleşmiyor';
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          child:
                              _loading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(_isLogin ? 'Giriş' : 'Kayıt'),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin ? 'Hesabın yok mu?' : 'Hesabın var mı?',
                          ),
                          TextButton(
                            onPressed:
                                _loading
                                    ? null
                                    : () =>
                                        setState(() => _isLogin = !_isLogin),
                            child: Text(_isLogin ? 'Kayıt ol' : 'Giriş yap'),
                          ),
                        ],
                      ),

                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading ? null : _forgotPassword,
                            child: const Text('Şifremi unuttum?'),
                          ),
                        ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Divider(color: cs.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'ya da',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ),
                          Expanded(child: Divider(color: cs.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              _loading
                                  ? null
                                  : () async {
                                    setState(() => _loading = true);
                                    try {
                                      await AuthService().signInWithGoogle();
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _loading = false);
                                      }
                                    }
                                  },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'asset/brand/google.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.g_mobiledata),
                              ),
                              const SizedBox(width: 10),
                              const Text('Google ile devam et'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final score = _score(password);
    final frac = (score / 5).clamp(0.0, 1.0);

    String label;
    if (score <= 1) {
      label = 'Çok zayıf';
    } else if (score == 2) {
      label = 'Zayıf';
    } else if (score == 3) {
      label = 'Orta';
    } else if (score == 4) {
      label = 'Güçlü';
    } else {
      label = 'Çok güçlü';
    }

    Color barColor;
    if (score <= 2) {
      barColor = cs.error;
    } else if (score == 3) {
      barColor = cs.tertiary;
    } else {
      barColor = cs.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 8,
            color: barColor,
            backgroundColor: cs.surfaceContainerHigh,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Şifre gücü: $label',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static int _score(String s) {
    if (s.isEmpty) return 0;
    var pts = 0;
    if (s.length >= 8) pts++;
    if (RegExp(r'[A-Z]').hasMatch(s)) pts++;
    if (RegExp(r'[a-z]').hasMatch(s)) pts++;
    if (RegExp(r'\d').hasMatch(s)) pts++;
    if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]{};:"\\|,.<>\/?`~]').hasMatch(s)) {
      pts++;
    }
    return pts;
  }
}

class _PasswordRulesChecklist extends StatelessWidget {
  const _PasswordRulesChecklist({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final hasLen = password.length >= 8;
    final hasUp = RegExp(r'[A-Z]').hasMatch(password);
    final hasLow = RegExp(r'[a-z]').hasMatch(password);
    final hasNum = RegExp(r'\d').hasMatch(password);
    final hasSpec = RegExp(
      r'[!@#\$%\^&\*\(\)_\+\-=\[\]{};:"\\|,.<>\/?`~]',
    ).hasMatch(password);

    Widget row(bool ok, String text) => Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: ok ? cs.primary : cs.error,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(hasLen, 'En az 8 karakter'),
        const SizedBox(height: 4),
        row(hasUp, 'En az 1 büyük harf (A-Z)'),
        const SizedBox(height: 4),
        row(hasLow, 'En az 1 küçük harf (a-z)'),
        const SizedBox(height: 4),
        row(hasNum, 'En az 1 rakam (0-9)'),
        const SizedBox(height: 4),
        row(hasSpec, 'En az 1 özel karakter (!, @, #, …)'),
      ],
    );
  }
}
