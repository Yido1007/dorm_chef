import 'package:dorm_chef/widget/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dorm_chef/service/auth.dart'; // varsa kullanacağız

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
                  // TODO: Kişisel bilgiler ekranına git
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.language,
                title: 'Uygulama Dili',
                subtitle: 'Uygulama dilini değiştirebilirsiniz',
                onTap: () {
                  // TODO: Dil seçimi
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.lock,
                title: 'Şifre İşlemleri',
                subtitle: 'Şifrenizi güncelleyebilirsiniz',
                onTap: () {
                  // TODO: Şifre güncelleme ekranı
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.brightness_6,
                title: 'Tema Görünümü',
                subtitle: 'Uygulama görünümünü değiştirebilirsiniz',
                onTap: () {
                  // TODO: Tema seçim sayfası / bottom sheet
                },
              ),
              _Divider(cs),
              SettingTile(
                icon: Icons.notifications,
                title: 'Bildirim Ayarları',
                subtitle: 'Bildirim ayarlarınızı değiştirebilirsiniz',
                onTap: () {
                  // TODO: Bildirim ayarları
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
                  try {
                    await AuthService().signOut();
                  } catch (_) {
                    await FirebaseAuth.instance.signOut();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
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
