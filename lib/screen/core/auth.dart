import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
    // Firebase e-postaları için UI dilini ayarla
    FirebaseAuth.instance.setLanguageCode(context.locale.languageCode);

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
              title: Text('forgot_password_q'.tr()),
              content: TextField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  border: const OutlineInputBorder(),
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

    // Firebase e-postaları için dil
    FirebaseAuth.instance.setLanguageCode(context.locale.languageCode);

    if (!mounted) return;
    setState(() => _loading = true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('reset_email_sent'.tr())));
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-email' => 'valid_email_required'.tr(),
        'missing-email' => 'valid_email_required'.tr(),
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
        return 'weak_password_policy'.tr();
      case 'email-already-in-use':
        return 'email_in_use'.tr();
      case 'invalid-email':
        return 'invalid_email'.tr();
      case 'wrong-password':
        return 'wrong_password'.tr();
      default:
        return 'Hata: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'login'.tr() : 'register'.tr()),
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
                              _isLogin ? 'login'.tr() : 'register'.tr(),
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
                          decoration: InputDecoration(
                            labelText: 'name'.tr(),
                            hintText: 'name'.tr(),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'name_required'.tr();
                            if (t.length < 2) return 'name_min'.tr();
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: 'email'.tr(),
                          hintText: 'email'.tr(),
                          prefixIcon: const Icon(Icons.alternate_email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator:
                            (v) =>
                                (v == null || !v.contains('@'))
                                    ? 'valid_email_required'.tr()
                                    : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _pass,
                        decoration: InputDecoration(
                          labelText: 'password'.tr(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obPass = !_obPass),
                            icon: Icon(
                              _obPass ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: _obPass,
                        onChanged:
                            (_) => setState(() {}), // güç çubuğu / checklist
                        validator: (v) {
                          final s = v ?? '';
                          if (s.isEmpty) return 'password_required'.tr();
                          return null; // kuralları Firebase uygular
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
                            labelText: 'password_repeat'.tr(),
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
                            if (v == null || v.isEmpty)
                              return 'password_again_required'.tr();
                            if (v != _pass.text)
                              return 'password_mismatch'.tr();
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
                                  : Text(
                                    _isLogin ? 'login'.tr() : 'register'.tr(),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'no_account_q'.tr()
                                : 'have_account_q'.tr(),
                          ),
                          TextButton(
                            onPressed:
                                _loading
                                    ? null
                                    : () =>
                                        setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin ? 'register'.tr() : 'login'.tr(),
                            ),
                          ),
                        ],
                      ),

                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading ? null : _forgotPassword,
                            child: Text('forgot_password_q'.tr()),
                          ),
                        ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Divider(color: cs.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'or'.tr(),
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
                            side: BorderSide(color: cs.outlineVariant),
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
                                        SnackBar(
                                          content: Text(
                                            'signup_google_error'.tr(),
                                          ),
                                        ),
                                      );
                                    } finally {
                                      if (mounted)
                                        setState(() => _loading = false);
                                    }
                                  },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/brands/google_g.png',
                                width: 18,
                                height: 18,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.g_mobiledata),
                              ),
                              const SizedBox(width: 10),
                              Text('continue_with_google'.tr()),
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

/* ---------- Bilgilendirici şifre gücü & kurallar (i18n) ---------- */

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final score = _score(password); // 0..5
    final frac = (score / 5).clamp(0.0, 1.0);

    String levelKey;
    if (score <= 1) {
      levelKey = 'pwd_level_very_weak';
    } else if (score == 2) {
      levelKey = 'pwd_level_weak';
    } else if (score == 3) {
      levelKey = 'pwd_level_medium';
    } else if (score == 4) {
      levelKey = 'pwd_level_strong';
    } else {
      levelKey = 'pwd_level_very_strong';
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
          'pwd_strength'.tr(namedArgs: {'level': levelKey.tr()}),
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
    if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]{};:"\\|,.<>\/?`~]').hasMatch(s))
      pts++;
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

    Widget row(bool ok, String key) => Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: ok ? cs.primary : cs.error,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(key.tr())),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(hasLen, 'rule_min_len'),
        const SizedBox(height: 4),
        row(hasUp, 'rule_upper'),
        const SizedBox(height: 4),
        row(hasLow, 'rule_lower'),
        SizedBox(height: 4),
        row(hasNum, 'rule_digit'),
        const SizedBox(height: 4),
        row(hasSpec, 'rule_special'),
      ],
    );
  }
}
