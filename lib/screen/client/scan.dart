import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../provider/ingredient.dart';
import '../../service/scan.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with AutomaticKeepAliveClientMixin {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _handling = false; // Aynı anda birden fazla okuma olmasın
  Timer? _cooldown; // Peş peşe tetiklemeyi yavaşlat
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _cooldown?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('scan'.tr()),
        actions: [
          IconButton(
            tooltip: 'flash'.tr(),
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () async {
              try {
                await _controller.toggleTorch();
              } catch (e) {
                debugPrint('Torch err: $e');
              }
            },
          ),
          IconButton(
            tooltip: 'camera'.tr(),
            icon: const Icon(Icons.cameraswitch_outlined),
            onPressed: () async {
              try {
                await _controller.switchCamera();
              } catch (e) {
                debugPrint('Switch err: $e');
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              if (_handling) return;

              final codes = capture.barcodes;
              if (codes.isEmpty) return;
              final raw = codes.first.rawValue;
              if (raw == null || raw.trim().isEmpty) return;

              // basit cooldown (1 sn)
              if (_cooldown != null && _cooldown!.isActive) return;
              _cooldown = Timer(const Duration(seconds: 1), () {});

              _handling = true;
              try {
                await _handleBarcode(raw.trim());
              } finally {
                // kısa gecikme sonra tekrar okusun
                Future<void>.delayed(const Duration(milliseconds: 600)).then((
                  _,
                ) {
                  if (mounted) _handling = false;
                });
              }
            },
            errorBuilder: (BuildContext context, MobileScannerException error) {
              debugPrint('MobileScanner error: $error');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'camera_start_failed_with_err'.tr(
                      namedArgs: {'err': '$error'},
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          // Basit vizör
          IgnorePointer(
            ignoring: true,
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: cs.primary, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBarcode(String code) async {
    final store = context.read<PantryStore>();

    // 1) OFF'tan ürün adını çözmeye çalış
    String? labelFromApi;
    try {
      labelFromApi = await BarcodeLookup.lookupLabel(code);
    } catch (e) {
      debugPrint('OFF lookup error: $e');
    }

    if (labelFromApi != null && labelFromApi.trim().isNotEmpty) {
      await store.addByLabel(labelFromApi.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'added_to_inventory_with_label'.tr(
              namedArgs: {'label': labelFromApi},
            ),
          ),
        ),
      );
      return;
    }

    // 2) Bulunamazsa manuel giriş
    if (!mounted) return;
    final ctrl = TextEditingController();
    final decided = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'barcode_n'.tr(namedArgs: {'code': code}),
                  style: Theme.of(ctx).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'ingredient_name'.tr(),
                    hintText: 'ingredient_hint_example'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => Navigator.pop(ctx, true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('cancel'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(ctx, true),
                        icon: const Icon(Icons.add),
                        label: Text('add_to_inventory'.tr()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );

    if (decided == true) {
      final name = ctrl.text.trim();
      if (name.isNotEmpty) {
        await store.addByLabel(name);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'added_to_inventory_with_label'.tr(namedArgs: {'label': name}),
            ),
          ),
        );
      }
    }
  }
}
