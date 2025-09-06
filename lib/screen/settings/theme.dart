import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dorm_chef/provider/theme.dart';

class ThemeChangeScreen extends StatelessWidget {
  const ThemeChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mode = context.watch<ThemeController>().mode;

    final isLight = mode == ThemeMode.light;
    final isDark = mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Tema seçimi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Görsellerden birini seçerek temayı uygulayın',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ThemeOptionCard(
                    title: 'Açık Tema',
                    assetPath: 'asset/theme/light.png', // <- kendi görselin
                    selected: isLight,
                    onTap: () => _apply(context, ThemeMode.light),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ThemeOptionCard(
                    title: 'Koyu Tema',
                    assetPath: 'asset/theme/dark.png', // <- kendi görselin
                    selected: isDark,
                    onTap: () => _apply(context, ThemeMode.dark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // İstersen "Cihaz ayarı" butonu (opsiyonel):
            FilledButton.icon(
              onPressed: () => _apply(context, ThemeMode.system),
              icon: const Icon(Icons.phone_android),
              label: const Text('Cihaza göre'),
            ),
          ],
        ),
      ),
    );
  }

  void _apply(BuildContext context, ThemeMode m) {
    context.read<ThemeController>().setMode(m);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          m == ThemeMode.light
              ? 'Açık tema uygulandı'
              : m == ThemeMode.dark
              ? 'Koyu tema uygulandı'
              : 'Cihaz ayarına göre tema',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.title,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '$title temasını seç',
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant.withOpacity(.6),
              width: selected ? 2 : 1,
            ),
            boxShadow: kElevationToShadow[selected ? 2 : 0],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 9 / 19.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh, // kenar boşluk rengi
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8), // bezel etkisi
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Tam ekran ekran görüntüsünü kırpmadan göster
                        // Üstten hizalama, status bar/üst alan görünür kalsın
                        Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                        ),
                        // Seçiliyken hafif karartma + tik
                        if (selected) ...[
                          Container(color: Colors.black.withOpacity(.10)),
                          const Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              radius: 14,
                              child: Icon(Icons.check, size: 18),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Başlık
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
