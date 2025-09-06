import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<BoardingScreen> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  final _page = PageController();
  int _index = 0;

  void _next() {
    if (_index < 2) {
      _page.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'DormChef',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onFinished,
                    child: Text('skip'.tr()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _BoardPage(
                    icon: Icons.qr_code_scanner,
                    title: 'boarding_main_1'.tr(),
                    desc: 'boarding_alt_1'.tr(),
                  ),
                  _BoardPage(
                    icon: Icons.inventory_2,
                    title: 'boarding_main_2'.tr(),
                    desc: 'boarding_alt_2'.tr(),
                  ),
                  _BoardPage(
                    icon: Icons.restaurant_menu,
                    title: 'boarding_main_3'.tr(),
                    desc: 'boarding_alt_3'.tr(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _index == i ? 22 : 8,
                        decoration: BoxDecoration(
                          color:
                              _index == i
                                  ? cs.primary
                                  : cs.primary.withOpacity(.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(_index < 2 ? 'next'.tr() : 'start'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardPage extends StatelessWidget {
  const _BoardPage({
    required this.icon,
    required this.title,
    required this.desc,
  });
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Icon(icon, size: 92, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(desc, textAlign: TextAlign.center),
          const Spacer(),
        ],
      ),
    );
  }
}
