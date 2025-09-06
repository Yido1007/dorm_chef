import 'package:dorm_chef/screen/static/settings.dart';
import 'package:dorm_chef/service/avatar.dart';
import 'package:dorm_chef/widget/favorite/favorite_stripe.dart';
import 'package:dorm_chef/widget/home_tab/daily_carrousel.dart';
import 'package:dorm_chef/widget/home_tab/title.dart';
import 'package:dorm_chef/widget/settings/avatar_image.dart';
import 'package:dorm_chef/widget/text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  String bestDisplayName(User? user, {String fallback = 'Chef'}) {
    if (user == null) return fallback;

    final dn = user.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;

    for (final p in user.providerData) {
      final pdn = p.displayName?.trim();
      if (pdn != null && pdn.isNotEmpty) return pdn;
    }

    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return fallback;
  }

  String firstName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : fullName;
  }

  @override
  Widget build(BuildContext context) {
    final name = capFirstTr(
      firstName(bestDisplayName(FirebaseAuth.instance.currentUser)),
    );
    final safeName = (name.isEmpty) ? 'Chef' : name;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snap) {
        final user = snap.data;
        final name = capFirstTr(firstName(bestDisplayName(user)));
        final url = context.select<ProfileStore, String?>(
          (s) => s.resolvedPhotoUrl,
        );

        // Baş harf için ad/e-posta
        final u = FirebaseAuth.instance.currentUser;
        final displayName =
            (u?.displayName?.trim().isNotEmpty == true)
                ? u!.displayName!
                : (u?.email ?? '');
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'hi'.tr(namedArgs: {'name': (name.isEmpty ? 'Chef' : name)}),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingScreen()),
                    );
                  },
                  child: ProfileAvatar(
                    photoUrl: url, // foto varsa göster
                    displayName: displayName, // yoksa baş harf
                    size: 32, // AppBar için kompakt
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(top: 12),
            children: [
              HomeTabTitle(text: "daily_recipe".tr()),
              DailyRecipeCarousel(height: 230),
              HomeTabTitle(text: "fav_recipe".tr()),
              FavoritesStrip(),
            ],
          ),
        );
      },
    );
  }
}
