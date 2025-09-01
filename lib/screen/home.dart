import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'client/inventory.dart';
import 'client/recipes.dart';
import 'client/scan.dart';
import 'client/grocery.dart';
import 'static/home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // IndexedStack sıra sabitleri
  static const int _homeStack = 0;
  static const int _inventoryStack = 1;
  static const int _scanStack = 2; 
  static const int _groceryStack = 3;
  static const int _recipesStack = 4;

  // NavigationBar index'leri (Scan yok)
  static const int _homeNav = 0;
  static const int _inventoryNav = 1;
  static const int _groceryNav = 2;
  static const int _recipesNav = 3;

  int _stackIndex = _homeStack;
  int _lastNavIndex = _homeNav;

  late final List<Widget?> _tabs;

  @override
  void initState() {
    super.initState();

    _tabs = <Widget?>[
      const HomeTabScreen(),
      const InventoryScreen(),
      null, // <-- ScanScreen lazy
      const GroceryScreen(),
      const RecipesScreen(),
    ];


    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
    });
  }
  int _navToStack(int nav) => (nav < _groceryNav) ? nav : nav + 1;
  int _stackToNav(int stack) =>
      (stack <= _inventoryStack)
          ? stack
          : (stack >= _groceryStack)
          ? stack - 1
          : _lastNavIndex; // scan ise

  void _openScan() {
    setState(() {
      if (_tabs[_scanStack] == null) {
        _tabs[_scanStack] = const ScanScreen();
      }
      _stackIndex = _scanStack;

    });
  }

  void _closeScanIfOpen() {

    if (_stackIndex == _scanStack && _tabs[_scanStack] != null) {
      _tabs[_scanStack] = null;
    }
  }

  void _onNavSelected(int navIndex) {
    setState(() {
      _closeScanIfOpen();
      _lastNavIndex = navIndex;
      _stackIndex = _navToStack(navIndex);
    });
  }

  Future<bool> _onWillPop() async {
    if (_stackIndex == _scanStack) {
      setState(() {
        _closeScanIfOpen();
        _stackIndex = _navToStack(_lastNavIndex);
      });
      return false; 
    }

    if (_stackIndex != _homeStack) {
      setState(() {
        _stackIndex = _homeStack;
        _lastNavIndex = _homeNav;
      });
      return false;
    }
    return true; 
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true, 
        body: IndexedStack(
          index: _stackIndex,
          children: _tabs.map((w) => w ?? const SizedBox.shrink()).toList(),
        ),
        floatingActionButton: SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            heroTag: 'scanFab',
            onPressed: _openScan,
            shape: const CircleBorder(),
            child: const Icon(Icons.qr_code_scanner, size: 28),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

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
                selectedIndex: _stackToNav(_stackIndex),
                onDestinationSelected: _onNavSelected,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_filled),
                    label: "main_screen".tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.inventory_2_outlined),
                    selectedIcon: const Icon(Icons.inventory_2),
                    label: 'inventory'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    selectedIcon: const Icon(Icons.shopping_cart),
                    label: 'cart'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.restaurant_menu_outlined),
                    selectedIcon: const Icon(Icons.restaurant_menu),
                    label: 'recipe'.tr(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
