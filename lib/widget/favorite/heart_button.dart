import 'package:dorm_chef/provider/favorite.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteHeartButton extends StatelessWidget {
  const FavoriteHeartButton({super.key, required this.recipeId});
  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoriteStore>();
    final isFav = fav.isFavorite(recipeId);
    final user = FirebaseAuth.instance.currentUser;

    return IconButton(
      tooltip: isFav ? 'add_favorite'.tr() : 'remove_fav'.tr(),
      onPressed: () async {
        if (user == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('sign_fav'.tr())));
          return;
        }
        await context.read<FavoriteStore>().toggle(recipeId);
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(
          key: ValueKey(isFav),
          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        ),
      ),
    );
  }
}
