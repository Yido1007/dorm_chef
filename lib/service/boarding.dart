import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _kKey = 'onboarding_seen_v1';

  static Future<bool> hasSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kKey) ?? false;
  }

  static Future<void> setSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kKey, true);
  }

  // Geliştirici testi için:
  static Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kKey);
  }
}
