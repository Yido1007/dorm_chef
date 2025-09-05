// lib/service/avatar.dart
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileStore extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  String? _customPhotoUrl; // aktif kullanıcının custom avatarı (Firestore)
  String? _photoPath; // Storage içindeki tam yol
  bool _busy = false;

  StreamSubscription<User?>? _authSub;
  String? _boundUid;

  bool get busy => _busy;
  bool get hasCustom => _customPhotoUrl?.isNotEmpty == true;
  String? get customPhotoUrl => _customPhotoUrl;
  String? get googlePhotoUrl => _auth.currentUser?.photoURL;

  /// UI'nin göstereceği URL: önce custom, yoksa Google
  String? get resolvedPhotoUrl => _customPhotoUrl ?? googlePhotoUrl;

  /// Oturum değişimlerini dinle ve store’u doğru kullanıcıya bağla
  void bindAuth() {
    _authSub?.cancel();
    _authSub = _auth.userChanges().listen(onAuthChanged, onError: (_) {});
    onAuthChanged(_auth.currentUser); // mevcut oturum için ilk yükleme
  }

  void onAuthChanged(User? user) {
    final uid = user?.uid;
    if (uid == null) {
      _boundUid = null;
      _customPhotoUrl = null;
      _photoPath = null;
      notifyListeners();
      return;
    }
    if (_boundUid == uid) return; // aynı kullanıcıysa no-op
    _boundUid = uid;
    _loadForUid(uid);
  }

  Future<void> _loadForUid(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      _customPhotoUrl = doc.data()?['photoUrl'] as String?;
      _photoPath = doc.data()?['photoPath'] as String?;
    } catch (_) {
      _customPhotoUrl = null;
      _photoPath = null;
    }
    notifyListeners();
  }

  // Türkçe karakterleri sadeleştir + path’e uygun hale getir
  String _sanitize(String input) {
    final map = {
      'ç': 'c',
      'Ç': 'c',
      'ğ': 'g',
      'Ğ': 'g',
      'ı': 'i',
      'İ': 'i',
      'ö': 'o',
      'Ö': 'o',
      'ş': 's',
      'Ş': 's',
      'ü': 'u',
      'Ü': 'u',
    };
    final replaced = input.split('').map((ch) => map[ch] ?? ch).join();
    final lower = replaced.toLowerCase().trim();
    final noSpace = lower.replaceAll(RegExp(r'\s+'), '_');
    final safe = noSpace.replaceAll(RegExp(r'[^a-z0-9_\-]'), '');
    return safe.isEmpty ? 'user' : safe;
  }

  /// Kameradan/Galeri’den yükle: kullanıcı **ismiyle** ve **versiyonlu** kaydet
  Future<void> uploadFrom(ImageSource source) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    _busy = true;
    notifyListeners();
    try {
      final display =
          user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : (user.email ?? 'user');
      final safeName = _sanitize(display);
      final ts = DateTime.now().millisecondsSinceEpoch;
      // => users/<uid>/profile_<kullanici-adi>_<timestamp>.jpg
      final path = 'users/${user.uid}/profile_${safeName}_$ts.jpg';

      // eski dosyayı temizle (varsa)
      final prevPath = _photoPath;
      if (prevPath != null && prevPath.isNotEmpty) {
        await _storage.ref(prevPath).delete().catchError((_) {});
      }

      final ref = _storage.ref(path);
      await ref.putFile(
        File(picked.path),
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=604800',
          customMetadata: {
            'uid': user.uid,
            'displayName': display,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final url = await ref.getDownloadURL();
      await _db.collection('users').doc(user.uid).set({
        'displayName': display,
        'photoUrl': url,
        'photoPath': path,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updatePhotoURL(url).catchError((_) {});

      _customPhotoUrl = url;
      _photoPath = path;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Avatarı kaldır (Storage + Firestore temizliği)
  Future<void> removePhoto() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _busy = true;
    notifyListeners();
    try {
      final path = _photoPath ?? 'users/${user.uid}/profile.jpg';
      await _storage.ref(path).delete().catchError((_) {});
      await _db.collection('users').doc(user.uid).set({
        'photoUrl': FieldValue.delete(),
        'photoPath': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.updatePhotoURL(null).catchError((_) {});
      _customPhotoUrl = null;
      _photoPath = null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
