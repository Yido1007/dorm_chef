
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.okLabel,
    this.cancelLabel,
    this.icon,
    this.danger = false,
  });
  final String title;
  final String message;
  final String? okLabel;
  final String? cancelLabel;
  final IconData? icon;
  final bool danger;
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? okLabel,
    String? cancelLabel,
    IconData? icon,
    bool danger = false,
    bool barrierDismissible = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (_) => ConfirmDialog(
            title: title,
            message: message,
            okLabel: okLabel,
            cancelLabel: cancelLabel,
            icon: icon,
            danger: danger,
          ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final okText = okLabel ?? 'ok'.tr();
    final cancelText = cancelLabel ?? 'cancel'.tr();

    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: cs.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 2,
            ),
          ),
        ],
      ),
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          style:
              danger
                  ? FilledButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                  )
                  : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(okText),
        ),
      ],
    );
  }
}
