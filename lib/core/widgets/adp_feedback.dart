import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';

abstract final class AdpFeedback {
  static void failure(BuildContext context, {
    required String source,
    required String message,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdpColors.ink,
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.error_outline_rounded,
                    color: AdpColors.terracotta, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$source\n$message',
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
}