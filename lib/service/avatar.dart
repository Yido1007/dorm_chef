// lib/provider/profile.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileStore extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;

  String? _customPhotoUrl; 
  bool _busy = false;

  bool get busy => _busy;
  String? get customPhotoUrl => _customPhotoUrl;

  String? get googlePhotoUrl => _auth.currentUser?.photoURL;
  String? get resolvedPhotoUrl => _customPhotoUrl ?? googlePhotoUrl;

  Future<void> ensure() async {
  }
}
