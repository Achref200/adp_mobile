import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';

/// Compact referral chip used on the membership flow.
///
/// It stays optional and calm, but it can open a real member search
/// so the admin can trace who introduced a new member.
class AdpReferralChip extends StatelessWidget {
  const AdpReferralChip({
    super.key,
    required this.selectedReferrer,
    required this.onTap,
    required this.label,
    this.hint,
    this.accessory,
  });
  final User? selectedReferrer;
  final VoidCallback onTap;
  final String label;
  final String? hint;
  final Widget? accessory;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedReferrer != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AdpColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasSelection
                  ? AdpColors.tealDeep.withValues(alpha: 0.35)
                  : AdpColors.ink.withValues(alpha: 0.05),
              width: hasSelection ? 1.25 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasSelection
                            ? AdpColors.tealDeep
                            : AdpColors.muted,
                      ),
                    ),
                    if (hint != null)
                      Text(
                        hint!,
                        style: const TextStyle(
                            fontSize: 11, color: AdpColors.mutedLight),
                      ),
                  ],
                ),
              ),
              if (accessory != null) accessory!,
            ],
          ),
        ),
      ),
    );
  }
}
