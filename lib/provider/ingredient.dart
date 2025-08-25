import 'dart:collection';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/ingredient.dart';
import '../service/norm.dart';

/// Kullanıcıya bağlı envanter (Firestore)
///
/// Firestore yolu: users/{uid}/pantry/{docId}
/// docId = norm(label) (aynı üründen tek kayıt, miktar atomik artar)
class PantryStore extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _uid;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  final List<PantryItem> _catalog = [];
  UnmodifiableListView<PantryItem> get list => UnmodifiableListView(_catalog);

  /// Uyum için bırakıldı (Hive’dan taşıma). Artık bir şey yapmıyor.
  Future<void> warmUp() async => Future.value();

  /// Oturum açan kullanıcıya bağlan; canlı dinleme başlat.
  Future<void> bind(String uid) async {
    if (_uid == uid) return;
    await unbind();
    _uid = uid;

    _sub = _db
        .collection('users')
        .doc(uid)
        .collection('pantry')
        .orderBy('label')
        .snapshots()
        .listen((snap) {
          _catalog
            ..clear()
            ..addAll(
              snap.docs.map((d) {
                final m = d.data();
                return PantryItem(
                  id: d.id,
                  label: (m['label'] as String?) ?? d.id,
                  amount: (m['amount'] as int?) ?? 0,
                );
              }),
            );
          notifyListeners();
        });
  }

  /// Kullanıcıdan ayrıl; dinlemeyi kapat ve belleği temizle.
  Future<void> unbind() async {
    await _sub?.cancel();
    _sub = null;
    _uid = null;
    _catalog.clear();
    notifyListeners();
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('pantry');

  // ----------------- Mutasyonlar (tamamı kalıcı) -----------------

  /// Ada göre ekle/varsa miktar arttır (uyum için yedek).
  Future<void> addByLabel(String label, {int start = 1}) =>
      addOrIncrease(label, by: start);

  /// Ada göre ekle veya miktarı atomik olarak artır.
  Future<void> addOrIncrease(String label, {int by = 1}) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError(
        'PantryStore is not bound to a user. Call bind(uid) first.',
      );
    }
    final id = norm(label);
    await _col(uid).doc(id).set({
      'label': label,
      'norm': id,
      'amount': FieldValue.increment(by),
    }, SetOptions(merge: true));
  }

  /// Miktarı doğrudan ayarla (0..1000 arası kısılır).
  Future<void> setAmount(String id, int value) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError(
        'PantryStore is not bound to a user. Call bind(uid) first.',
      );
    }
    final v = value.clamp(0, 1000);
    await _col(uid).doc(id).set({'amount': v}, SetOptions(merge: true));
  }

  Future<void> increase(String id, [int step = 1]) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError(
        'PantryStore is not bound to a user. Call bind(uid) first.',
      );
    }
    await _col(uid).doc(id).update({'amount': FieldValue.increment(step)});
  }

  Future<void> decrease(String id, [int step = 1]) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError(
        'PantryStore is not bound to a user. Call bind(uid) first.',
      );
    }
    final ref = _col(uid).doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final current = (snap.data()?['amount'] as int?) ?? 0;
      final next = current - step;
      if (next <= 0) {
        tx.delete(ref);
      } else {
        tx.update(ref, {'amount': next});
      }
    });
  }

  Future<void> deleteById(String id) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError(
        'PantryStore is not bound to a user. Call bind(uid) first.',
      );
    }
    await _col(uid).doc(id).delete();
  }

  Future<void> clearEverything() async {
    final uid = _uid;
    if (uid == null) {
      throw StateError(
        'PantryStore is not bound to a user. Call bind(uid) first.',
      );
    }
    final col = _col(uid);
    final batch = _db.batch();
    final docs = await col.get();
    for (final d in docs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
