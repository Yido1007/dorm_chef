import 'package:dorm_chef/provider/ingredient.dart';
import 'package:dorm_chef/screen/core/change_pass.dart';
import 'package:dorm_chef/screen/core/language.dart';
import 'package:dorm_chef/screen/core/notification.dart';
import 'package:dorm_chef/screen/core/profile.dart';
import 'package:dorm_chef/screen/core/theme.dart';
import 'package:dorm_chef/widget/section_card.dart';
import 'package:dorm_chef/widget/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:dorm_chef/service/auth.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ThemeChangeScreen(),
                    ),
                  );
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
                  // TODO: İletişim
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
