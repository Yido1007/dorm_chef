import 'package:dorm_chef/widget/is_empty.dart';
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
    // Hive kutusunu hazırla (UI’yi bloklamasın)
    Future.microtask(() => context.read<GroceryBag>().ensure());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryBag>(
      builder: (context, bag, _) {
        final items = bag.items;

        return Scaffold(
          appBar: AppBar(
            title: Text('cart'.tr()),
            actions: [
              IconButton(
                tooltip: 'clear_cart'.tr(),
                onPressed:
                    items.isEmpty
                        ? null
                        : () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: Text('delete_all'.tr()),
                                  content: Text('cart_delete'.tr()),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: Text('cancel'.tr()),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text('delete'.tr()),
                                    ),
                                  ],
                                ),
                          );
                          if (ok == true) {
                            await context.read<GroceryBag>().clear();
                          }
                        },
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),
          body:
              items.isEmpty
                  ? Empty(
                    "asset/icon/cart.png",
                    "cart_main".tr(),
                    "cart_alt".tr(),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      return CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: it.done,
                        onChanged: (_) => bag.toggle(it.id),
                        title: Text(
                          it.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration:
                                it.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        secondary: IconButton(
                          tooltip: 'remove'.tr(),
                          icon: const Icon(Icons.close),
                          onPressed: () => bag.remove(it.id),
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}
