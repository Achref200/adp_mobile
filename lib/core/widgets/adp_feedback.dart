import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';

/// The one voice of app feedback.
///
/// Every toast the user sees comes from here, so a success always feels
/// like a success and an error always feels like an error — no matter
/// which screen triggered it. Haptics ride along on purpose: success is
/// felt, not only read.
abstract final class AdpFeedback {
  static void _show(
    BuildContext context, {
    required Color accent,
    required IconData icon,
    required String title,
    String? detail,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdpColors.ink,
          duration: duration,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail == null || detail.isEmpty
                      ? title
                      : '$title\n$detail',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Quiet confirmation that an action landed well.
  /// Example: draft submitted, settings saved.
  static void success(
    BuildContext context, {
    required String title,
    String? detail,
  }) {
    _show(
      context,
      accent: AdpColors.success,
      icon: Icons.check_circle_rounded,
      title: title,
      detail: detail,
    );
  }

  /// Something needs attention but the app still works.
  /// Example: payment window could not open.
  static void failure(
    BuildContext context, {
    required String source,
    required String message,
  }) {
    _show(
      context,
      accent: AdpColors.terracotta,
      icon: Icons.error_outline_rounded,
      title: source,
      detail: message,
      duration: const Duration(seconds: 5),
    );
  }

  /// Neutral, short-lived information.
  /// Example: link copied, visibility toggled.
  static void info(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      accent: AdpColors.ocean,
      icon: Icons.info_outline_rounded,
      title: message,
      duration: const Duration(seconds: 2),
    );
  }
}
