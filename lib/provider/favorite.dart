import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FavoriteStore extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favSub;

  String? _uid;
  Set<String> _ids = <String>{};
  List<String> _orderedIds = <String>[];

  Set<String> get ids => _ids;
  List<String> get orderedIds => List.unmodifiable(_orderedIds);

  FavoriteStore() {
    // Auth değişince favori stream'ini yeniden kur
    _authSub = _auth.userChanges().listen((u) {
      _uid = u?.uid;
      _attachFavoritesStream();
    });

    _uid = _auth.currentUser?.uid;
    _attachFavoritesStream();
  }

  void _attachFavoritesStream() {

    _favSub?.cancel();
    _ids = <String>{};
    _orderedIds = <String>[];

    final uid = _uid;
    if (uid == null) {
      notifyListeners();
      return;
    }
    final col = _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true);
    _favSub = col.snapshots().listen(
      (snap) {
        _orderedIds = snap.docs.map((d) => d.id).toList();
        _ids = _orderedIds.toSet();
        notifyListeners();
      },
      onError: (err, st) {
        if (err is FirebaseException && err.code == 'unavailable') {
          return;
        }
        if (kDebugMode) {

        }
      },
      cancelOnError: false,
    );
  }

  bool isFavorite(String recipeId) => _ids.contains(recipeId);

  Future<void> toggle(String recipeId) async {
    final uid = _uid;
    if (uid == null || recipeId.isEmpty) return;

    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(recipeId);

    await _retryUnavailable(() async {
      final doc = await ref.get();
      if (doc.exists) {
        await ref.delete();
      } else {
        await ref.set({'createdAt': FieldValue.serverTimestamp()});
      }
    });
  }

  Future<T> _retryUnavailable<T>(Future<T> Function() fn) async {
    var delay = const Duration(milliseconds: 300);
    for (var i = 0; i < 4; i++) {
      try {
        return await fn();
      } on FirebaseException catch (e) {
        final lastTry = i == 3;
        if (e.code != 'unavailable' || lastTry) rethrow;
        await Future.delayed(delay);
        delay *= 2; // 300 → 600 → 1200 → 2400 ms
      }
    }
    throw StateError('retry failed');
  }

  @override
  void dispose() {
    _favSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
