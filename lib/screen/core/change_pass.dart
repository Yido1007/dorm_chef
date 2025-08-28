import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dorm_chef/service/auth.dart' show AuthService;
import 'package:easy_localization/easy_localization.dart';

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
      appBar: AppBar(title: Text('change_password_title'.tr())),
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
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Card(
        color: cs.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _currentCtrl,
                obscureText: _obCur,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'current_password'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obCur = !_obCur),
                    icon: Icon(
                      _obCur ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'current_password_required'.tr()
                            : null,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _newCtrl,
                obscureText: _obNew,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'new_password'.tr(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obNew = !_obNew),
                    icon: Icon(
                      _obNew ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final s = v ?? '';
                  if (s.isEmpty) return 'new_password_required'.tr();
                  if (s == _currentCtrl.text) {
                    return 'new_password_same_as_current'.tr();
                  }
                  return null; // kuralları Firebase enforce edecek
                },
              ),

              const SizedBox(height: 10),
              _PasswordStrengthBar(password: _newCtrl.text),
              const SizedBox(height: 8),
              _PasswordRulesChecklist(password: _newCtrl.text),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obCon,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'new_password_again'.tr(),
                  prefixIcon: const Icon(Icons.check),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obCon = !_obCon),
                    icon: Icon(
                      _obCon ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'reenter_new_password'.tr();
                  }
                  if (v != _newCtrl.text) return 'passwords_do_not_match'.tr();
                  return null;
                },
              ),

              const SizedBox(height: 16),
              _InfoHint(
                icon: Icons.info_outline,
                text: 'change_password_info'.tr(),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  onPressed: _loading ? null : () => _changePassword(user),
                  label:
                      _loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text('update_password'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderInfo(BuildContext context, User? user) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(height: 12),
            Text('account_uses_oauth_info'.tr(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.mail_outlined),
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
                                SnackBar(
                                  content: Text(
                                    'email_sent_create_password'.tr(),
                                  ),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (_isMounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_mapAuthError(e))),
                              );
                            }
                          }
                        },
                label: Text('email_create_reset_password'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword(User user) async {
    if (!_formKey.currentState!.validate()) return;
    final email = user.email;
    if (email == null || email.isEmpty) {
      _showSnack('email_not_found'.tr());
      return;
    }
    setState(() => _loading = true);
    try {
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
    } on TimeoutException {
      if (_isMounted) {
        setState(() => _loading = false);
        _showSnack('timeout_error'.tr());
      }
    } on FirebaseAuthException catch (e) {
      if (_isMounted) {
        setState(() => _loading = false);
        _showSnack(_mapAuthError(e));
      }
    } catch (e) {
      if (_isMounted) {
        setState(() => _loading = false);
        _showSnack('unexpected_error_with_err'.tr(namedArgs: {'err': '$e'}));
      }
    }
  }

  void _showSnack(String msg) {
    if (!_isMounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _mapAuthError(FirebaseAuthException e) {
    final msg = e.message;
    if (msg != null && msg.trim().isNotEmpty) return msg;
    switch (e.code) {
      case 'wrong-password':
        return 'error_wrong_password'.tr();
      case 'requires-recent-login':
        return 'error_requires_recent_login'.tr();
      case 'weak-password':
        return 'weak_password_policy'.tr(); // Firebase Password Policy
      case 'too-many-requests':
        return 'error_too_many_requests'.tr();
      case 'network-request-failed':
        return 'error_network'.tr();
      default:
        return 'error_code_prefix'.tr(namedArgs: {'code': e.code});
    }
  }
}

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
        const SizedBox(height: 4),
        row(hasNum, 'rule_digit'),
        const SizedBox(height: 4),
        row(hasSpec, 'rule_special'),
      ],
    );
  }
}

class _InfoHint extends StatelessWidget {
  const _InfoHint({required this.text, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.info_outline, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
