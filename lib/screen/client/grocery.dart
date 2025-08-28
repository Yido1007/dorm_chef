import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/grocery.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  @override
  void initState() {
    super.initState();
    // Hive kutusunu hazırla
    Future.microtask(() => context.read<GroceryBag>().ensure());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('cart'.tr()),
        actions: [
          IconButton(
            tooltip: 'clear_cart'.tr(),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: Text('delete_all'.tr()),
                      content: Text('cart_delete'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('cancel'.tr()),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('delete'.tr()),
                        ),
                      ],
                    ),
              );
              if (ok == true) await context.read<GroceryBag>().clear();
            },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Consumer<GroceryBag>(
        builder: (context, bag, _) {
          if (bag.items.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('cart_main'.tr()),
              ),
            );
          }
          return ListView.separated(
            itemCount: bag.items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final it = bag.items[i];
              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: it.done,
                onChanged: (_) => bag.toggle(it.id),
                title: Text(
                  it.label,
                  style: TextStyle(
                    decoration: it.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                secondary: IconButton(
                  tooltip: 'remove'.tr(),
                  icon: const Icon(Icons.close),
                  onPressed: () => bag.remove(it.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
