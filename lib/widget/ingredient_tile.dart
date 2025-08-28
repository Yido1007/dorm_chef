import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/ingredient.dart';
import '../provider/ingredient.dart';

class PantryItemTile extends StatelessWidget {
  final PantryItem data;
  const PantryItemTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String fmtNum(BuildContext context, num v) =>
        NumberFormat.decimalPattern(context.locale.toString()).format(v);
    return ListTile(
      onTap: () => _openAmountSheet(context, data),
      leading: const Icon(Icons.kitchen),
      title: Text(data.label),
      subtitle: Text(
        'amount_n'.tr(namedArgs: {'n': fmtNum(context, data.amount)}),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'reduce'.tr(),
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () async {
              await context.read<PantryStore>().decrease(data.id);
            },
          ),
          IconButton(
            tooltip: 'increase'.tr(),
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await context.read<PantryStore>().increase(data.id);
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'delete'.tr(),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: Text('delete_ing'.tr()),
                      content: Text(
                        'confirm_remove_label_q'.tr(
                          namedArgs: {'label': data.label},
                        ),
                      ),
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
              if (ok == true) {
                await context.read<PantryStore>().deleteById(data.id);
              }
            },
          ),
        ],
      ),
    );
  }

  void _openAmountSheet(BuildContext context, PantryItem data) {
    final store = context.read<PantryStore>();
    double value = data.amount.toDouble();
    String fmtNum(BuildContext context, num v) =>
        NumberFormat.decimalPattern(context.locale.toString()).format(v);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.label, style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'amount_n'.tr(
                      namedArgs: {'n': fmtNum(context, value.toInt())},
                    ),
                  ),
                  Slider(
                    min: 0,
                    max: 100,
                    divisions: 100,
                    value: value,
                    label: value.toInt().toString(),
                    onChanged: (v) => setState(() => value = v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () async {
                      await store.setAmount(data.id, value.toInt());
                      Navigator.pop(ctx);
                    },
                    child: Text('save'.tr()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
