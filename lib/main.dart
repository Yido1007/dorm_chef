import 'package:dorm_chef/screen/core/entry.dart';
import 'package:dorm_chef/service/avatar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/ingredient.dart';
import 'provider/grocery.dart';
import 'provider/theme.dart';
import 'provider/favorite.dart';
import 'service/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('it'),
        Locale('es'),
        Locale('fr'),
        Locale('pt'),
        Locale('ru'),
      ],
      path: 'asset/lang',
      fallbackLocale: const Locale('tr'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PantryStore()),
          ChangeNotifierProvider(create: (_) => GroceryBag()),
          ChangeNotifierProvider(create: (_) => ThemeController()..load()),
          ChangeNotifierProvider(create: (_) => FavoriteStore()),
          ChangeNotifierProvider(create: (_) => ProfileStore()..bindAuth()),
        ],
        child: const DormChefApp(),
      ),
    ),
  );
}

class DormChefApp extends StatelessWidget {
  const DormChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: context.watch<ThemeController>().mode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const AppEntry(),
    );
  }
}
