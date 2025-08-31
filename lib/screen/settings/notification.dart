// lib/screen/static/notification.dart
import 'package:dorm_chef/widget/settings/notification_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  PermissionStatus _cam = PermissionStatus.denied;
  PermissionStatus _noti = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _toggleCamera(bool wantOn) async {
    if (wantOn) {
      if (_cam.isPermanentlyDenied) {
        await _confirmOpenSettings(
          title: 'Kamera izni kapalı',
          message:
              'Kamera iznini açmak için sistem ayarlarına gitmeniz gerekir.',
        );
      } else {
        final res = await Permission.camera.request();
        if (!mounted) return;
        setState(() => _cam = res);
        _snack(_statusText(res));
      }
      return;
    }
    await _confirmOpenSettings(
      title: 'Kamera iznini kapat',
      message: 'Kamera iznini kapatmak için sistem ayarlarına gidin.',
    );
  }

  Future<void> _toggleNotification(bool wantOn) async {
    if (wantOn) {
      if (_noti.isPermanentlyDenied) {
        await _confirmOpenSettings(
          title: 'Bildirim izni kapalı',
          message:
              'Bildirim iznini açmak için sistem ayarlarına gitmeniz gerekir.',
        );
      } else {
        final res = await Permission.notification.request();
        if (!mounted) return;
        setState(() => _noti = res);
        _snack(_statusText(res));
      }
      return;
    }
    await _confirmOpenSettings(
      title: 'Bildirim iznini kapat',
      message: 'Bildirim iznini kapatmak için sistem ayarlarına gidin.',
    );
  }

  Future<void> _confirmOpenSettings({
    required String title,
    required String message,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ayarları aç'),
              ),
            ],
          ),
    );
    if (ok == true) {
      final opened = await openAppSettings();
      if (!opened && mounted) _snack('Ayarlar açılamadı');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _statusText(PermissionStatus s) {
    switch (s) {
      case PermissionStatus.granted:
        return 'İzin verildi';
      case PermissionStatus.denied:
        return 'Reddedildi';
      case PermissionStatus.permanentlyDenied:
        return 'Kalıcı reddedildi';
      case PermissionStatus.restricted:
        return 'Kısıtlı';
      case PermissionStatus.limited:
        return 'Sınırlı';
      case PermissionStatus.provisional:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('notifications'.tr())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SwitchCard(
            icon: Icons.camera_alt_outlined,
            title: 'Kamera izni',
            subtitle: 'Barkod tarama için gereklidir.',
            status: _statusText(_cam),

            value: _cam.isGranted,
            onChanged: _toggleCamera,
          ),
          const SizedBox(height: 12),
          SwitchCard(
            icon: Icons.notifications_active_outlined,
            title: 'Bildirim izni',
            subtitle: 'Duyurular ve hatırlatmalar için gereklidir.',
            status: _statusText(_noti),
            value: _noti.isGranted,
            onChanged: _toggleNotification,
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Ayarlar’dan yaptığınız değişiklikler bu ekrana döndüğünüzde otomatik yenilenir.',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
