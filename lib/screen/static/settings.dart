import 'package:dorm_chef/provider/ingredient.dart';
import 'package:dorm_chef/provider/theme.dart';
import 'package:dorm_chef/screen/core/change_pass.dart';
import 'package:dorm_chef/screen/core/language.dart';
import 'package:dorm_chef/screen/core/notification.dart';
import 'package:dorm_chef/screen/core/profile.dart';
import 'package:dorm_chef/widget/section_card.dart';
import 'package:dorm_chef/widget/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:dorm_chef/service/auth.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ana ayar grubu
          SectionCard(
            children: [
              SettingTile(
                icon: Icons.person,
                title: 'Kişisel Bilgiler',
                subtitle: 'Bilgilerinizi değiştirebilirsiniz',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.language,
                title: 'Uygulama Dili',
                subtitle: 'Uygulama dilini değiştirebilirsiniz',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  );
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.lock,
                title: 'Şifre İşlemleri',
                subtitle: 'Şifrenizi güncelleyebilirsiniz',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.brightness_6,
                title: 'Tema Görünümü',
                subtitle: 'Uygulama görünümünü değiştirebilirsiniz',
                onTap: () {
                  showThemePicker(context);
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.notifications,
                title: 'Bildirim Ayarları',
                subtitle: 'Bildirim ayarlarınızı değiştirebilirsiniz',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.support_agent,
                title: 'Bize Ulaşın',
                subtitle: 'Soru, öneri ve şikayetlerinizi iletin',
                onTap: () {
                  contactUs(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            children: [
              SettingTile(
                icon: Icons.logout,
                title: 'Çıkış Yap',
                subtitle: 'Uygulamadan çıkış yapabilirsiniz',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  await context.read<PantryStore>().unbind();
                  await AuthService().signOut();
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider(this.cs);
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: cs.outlineVariant.withOpacity(.3),
    );
  }
}

Uri _buildMailTo({
  required String to,
  required String subject,
  required String body,
}) {
  final q =
      'subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}';
  return Uri(scheme: 'mailto', path: to, query: q);
}

// Ayarlar > "Bize Ulaşın" onTap:
Future<void> contactUs(BuildContext context) async {
  const to = 'topcuyigithan@gmail.com';
  const subject = 'Dorm Chef';
  const body = 'Hi Chef Team';

  final mailto = _buildMailTo(to: to, subject: subject, body: body);

  if (Platform.isAndroid) {
    try {
      await AndroidIntent(
        action: 'android.intent.action.SENDTO',
        data: mailto.toString(),
      ).launch();
      return;
    } catch (_) {
      await launchUrl(mailto, mode: LaunchMode.externalApplication);
      return;
    }
  }
  if (await canLaunchUrl(mailto)) {
    await launchUrl(mailto, mode: LaunchMode.externalApplication);
  }
}

void showThemePicker(BuildContext context) {
  final ctrl = context.read<ThemeController>();
  ThemeMode selected = context.read<ThemeController>().mode;

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder:
        (ctx) => StatefulBuilder(
          builder:
              (ctx, setState) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(
                      title: Text(
                        'Tema Görünümü',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('Uygulama temasını seçin'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: selected,
                      onChanged: (v) => setState(() => selected = v!),
                      title: const Text('Sistem (Otomatik)'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: selected,
                      onChanged: (v) => setState(() => selected = v!),
                      title: const Text('Açık Tema'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: selected,
                      onChanged: (v) => setState(() => selected = v!),
                      title: const Text('Koyu Tema'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          await ctrl.setMode(selected);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Uygula'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
        ),
  );
}
