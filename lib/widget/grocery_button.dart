import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/grocery.dart';
import 'grocery_cart.dart';

class GroceryQuickButton extends StatefulWidget {
  const GroceryQuickButton({super.key});

  @override
  State<GroceryQuickButton> createState() => _GroceryQuickButtonState();
}

class _GroceryQuickButtonState extends State<GroceryQuickButton> {
  @override
  void initState() {
    super.initState();
    // Hive kutusunu hazırla (ilk kullanımda)
    Future.microtask(() => context.read<GroceryBag>().ensure());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryBag>(
      builder: (context, bag, _) {
        final pending = bag.items.where((e) => !e.done).length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Alışveriş Listesi',
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => showGrocerySheet(context),
            ),
            if (pending > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$pending',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
