import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/ingredient.dart';
import 'client/inventory.dart';
import 'client/recipes.dart';
import 'client/scan.dart';
import 'static/grocery.dart';
import 'static/home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // IndexedStack sıranız: 0 Ana, 1 Envanter, 2 Tara(FAB), 3 Sepet, 4 Tarifler
  int _stackIndex = 0;
  int _lastNavIndex = 0; // Tara'ya girip çıkınca hangi tab seçili kalsın

  late final List<Widget> _tabs = const [
    HomeTabScreen(),
    InventoryScreen(),
    ScanScreen(),
    GroceryScreen(),
    RecipesScreen(),
  ];

  void _onNavSelected(int navIndex) {
    setState(() {
      _lastNavIndex = navIndex;
      // navIndex: 0->0, 1->1, 2->3, 3->4  (2 Tara olmadığı için bir kaydırma var)
      _stackIndex = navIndex < 2 ? navIndex : navIndex + 1;
    });
  }

  @override
  void initState() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PantryStore>().bind(uid);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true, // FAB nav bar üstünde yarı saydam dursun
      body: IndexedStack(index: _stackIndex, children: _tabs),

      // Merkezde Tara (FAB) — basınca sadece stackIndex değişir
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          heroTag: 'scanFab',
          onPressed: () => setState(() => _stackIndex = 2),
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_scanner, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Alt NavigationBar — basit, taşma yok, notch yok
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: cs.primary,
              indicatorColor: cs.onPrimary.withOpacity(.12),
              iconTheme: MaterialStatePropertyAll(
                IconThemeData(color: cs.onPrimary),
              ),
              labelTextStyle: MaterialStatePropertyAll(
                Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: cs.onPrimary),
              ),
              height: 60,
            ),
            child: NavigationBar(
              selectedIndex: _lastNavIndex,
              onDestinationSelected: _onNavSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_filled),
                  label: 'Ana',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: 'Envanter',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: 'Sepet',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: 'Tarifler',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
