
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

  String?
  _customPhotoUrl; 
  bool _busy = false;

  bool get busy => _busy;
  bool get hasCustom => _customPhotoUrl?.isNotEmpty == true;
  String? get customPhotoUrl => _customPhotoUrl;
  String? get googlePhotoUrl => _auth.currentUser?.photoURL;

  String? get resolvedPhotoUrl => _customPhotoUrl ?? googlePhotoUrl;

  Future<void> ensure() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    _customPhotoUrl = (doc.data()?['photoUrl']) as String?;
    notifyListeners();
  }

  Future<void> uploadFrom(ImageSource source) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    _busy = true;
    notifyListeners();
    try {
      final file = File(picked.path);
      final ref = _storage.ref('users/$uid/profile.jpg');
      await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=604800', 
        ),
      );
      final url = await ref.getDownloadURL();

      await _db.collection('users').doc(uid).set({
        'photoUrl': url,
      }, SetOptions(merge: true));

      await _auth.currentUser!.updatePhotoURL(url);

      _customPhotoUrl = url;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> removePhoto() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _busy = true;
    notifyListeners();
    try {
      final ref = _storage.ref('users/$uid/profile.jpg');
      await ref.delete().catchError((_) {}); 
      await _db.collection('users').doc(uid).set({
        'photoUrl': FieldValue.delete(),
      }, SetOptions(merge: true));
      await _auth.currentUser!.updatePhotoURL(null);
      _customPhotoUrl = null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
