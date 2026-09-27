import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Humanized haptic feedback for ADP touch interactions.
/// Uses the platform's native haptic engine (iOS Core Haptics / Android Vibration).
/// On web and unsupported platforms this is a no-op.
abstract final class AdpHaptic {
  /// Light tap — buttons, list items, toggle switches.
  static void tap() {
    if (kIsWeb || !HapticFeedback.supportsVibration) return;
    HapticFeedback.lightImpact();
  }

  /// Medium selection — radio/checkbox selection, tab switch, plan selection.
  static void select() {
    if (kIsWeb || !HapticFeedback.supportsVibration) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy — successful submit, payment confirmation, membership validated.
  static void success() {
    if (kIsWeb || !HapticFeedback.supportsVibration) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection of a referral/member from the list.
  static void referrerSelected() {
    if (kIsWeb || !HapticFeedback.supportsVibration) return;
    HapticFeedback.selectionClick();
  }
}
