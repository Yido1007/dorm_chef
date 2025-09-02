// lib/widget/profile/profile_avatar.dart
import 'package:flutter/material.dart';
import 'package:characters/characters.dart'; // <= BUNU EKLE

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.displayName,
    this.size = 100,
    this.onTap,
  });

  final String? photoUrl;
  final String? displayName;
  final double size;
  final VoidCallback? onTap;

  String _initials(String? s) {
    final t = (s ?? '').trim();
    if (t.isEmpty) return '🙂';
    final parts = t.split(RegExp(r'\s+'));
    final take =
        parts.length >= 2
            ? (parts.first.characters.first + parts.last.characters.first)
            : parts.first.characters.first;
    final v = take.toUpperCase();
    return v.isEmpty ? '🙂' : v;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = _initials(displayName);

    return InkWell(
      borderRadius: BorderRadius.circular(size),
      onTap: onTap,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: cs.surfaceVariant,
        // Foto varsa kullan; yoksa child her zaman çizilecek
        foregroundImage:
            (photoUrl != null && photoUrl!.isNotEmpty)
                ? NetworkImage(photoUrl!)
                : null,
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
