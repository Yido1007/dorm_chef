import 'package:dorm_chef/provider/favorite.dart';
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
      tooltip: isFav ? 'Favorilerden çıkar' : 'Favorilere ekle',
      onPressed: () async {
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favori eklemek için giriş yapın')),
          );
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
