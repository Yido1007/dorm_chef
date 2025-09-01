import 'dart:async' show unawaited;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_chef/widget/text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _prefill() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String display = user.displayName?.trim() ?? _emailLocalPart(user.email);
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final fsName = (snap.data()?['displayName'] as String?)?.trim();
      if (fsName != null && fsName.isNotEmpty) display = fsName;
    } catch (_) {}
    _nameCtrl.text = capFirstTr(display);
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('session_not_found'.tr());
      return;
    }

    final uid = user.uid;
    final newName = capFirstTr(_nameCtrl.text);

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    unawaited(
      FirebaseAuth.instance.currentUser!
          .updateDisplayName(newName)
          .catchError((_) {}),
    );
    unawaited(
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
            'displayName': newName,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .catchError((_) {}),
    );
    unawaited(FirebaseAuth.instance.currentUser?.reload().catchError((_) {}));

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('profile_title'.tr()), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'name_label'.tr(),
                      hintText: 'name_hint'.tr(),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'name_required'.tr();
                      if (t.length < 2) return 'name_min2'.tr();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'email_label'.tr(),
                      suffixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child:
                          _saving
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text('save'.tr()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'profile_name_hint'.tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
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

String _emailLocalPart(String? email) {
  if (email == null || !email.contains('@')) return 'Chef';
  return email.split('@').first;
}
