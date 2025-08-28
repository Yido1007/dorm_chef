import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Locale? _selected;

  final _langs = <_Lang>[
    _Lang(flag: '🇹🇷', name: 'Türkçe', locale: const Locale('tr')),
    _Lang(flag: '🇺🇸', name: 'English', locale: const Locale('en')),
    // _Lang(flag: '🇫🇷', name: 'Français', locale: const Locale('fr')),
    // _Lang(flag: '🇺🇦', name: 'Українська', locale: const Locale('uk')),
    // _Lang(flag: '🇷🇺', name: 'Русский', locale: const Locale('ru')),
    // _Lang(flag: '🇩🇪', name: 'Deutsch', locale: const Locale('de')),
    // _Lang(flag: '🇪🇸', name: 'Español', locale: const Locale('es')),
    // _Lang(flag: '🇮🇹', name: 'Italiano', locale: const Locale('it')),
    // _Lang(flag: '🇵🇹', name: 'Português', locale: const Locale('pt')),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected ??= context.locale;
  }

  bool _sameLocale(Locale a, Locale b) =>
      a.languageCode == b.languageCode &&
      (a.countryCode ?? '') == (b.countryCode ?? '');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final supported = context.supportedLocales;
    final selected = _selected ?? context.locale;

    return Scaffold(
      appBar: AppBar(title: Text('Uygulama Dili'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.separated(
            itemCount: _langs.length,
            separatorBuilder:
                (_, __) => Divider(
                  height: 1,
                  color: cs.outlineVariant.withOpacity(.5),
                  indent: 72,
                  endIndent: 16,
                ),
            itemBuilder: (context, i) {
              final item = _langs[i];
              final isSelected = _sameLocale(selected, item.locale);
              final isSupported = supported.any(
                (l) => _sameLocale(l, item.locale),
              );

              return InkWell(
                borderRadius:
                    i == 0
                        ? const BorderRadius.vertical(top: Radius.circular(20))
                        : i == _langs.length - 1
                        ? const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        )
                        : BorderRadius.zero,
                onTap: () => setState(() => _selected = item.locale),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(item.flag, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _TrailingSelect(
                        selected: isSelected,
                        enabled: isSupported,
                        selectedColor: cs.secondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            onPressed: () async {
              final ok = supported.any((l) => _sameLocale(l, selected));
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bu dil henüz desteklenmiyor.'.tr())),
                );
                return;
              }
              await context.setLocale(selected);
              if (mounted) Navigator.pop(context, true);
            },
            child: Text('Kaydet'.tr()),
          ),
        ),
      ),
    );
  }
}

class _TrailingSelect extends StatelessWidget {
  const _TrailingSelect({
    required this.selected,
    required this.enabled,
    required this.selectedColor,
  });

  final bool selected;
  final bool enabled;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (selected) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 18, color: Colors.black),
      );
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: enabled ? cs.onSurfaceVariant : cs.outlineVariant,
          width: 2,
        ),
      ),
    );
  }
}

class _Lang {
  final String flag;
  final String name;
  final Locale locale;
  const _Lang({required this.flag, required this.name, required this.locale});
}
