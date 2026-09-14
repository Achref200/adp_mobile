import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/design/adp_components.dart';
import 'package:flutter/material.dart';

/// Core Unified State Controller Component
/// Manages Content, Loading (with Shimmer Skeleton), Empty, and Error states
/// to guarantee visual chemistry and harmony across all features.
class AdpStateView<T> extends StatelessWidget {
  const AdpStateView({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
    required this.data,
    required this.contentBuilder,
    this.errorMessage,
    this.onRetry,
    this.emptyTitle = 'Aucun élément trouvé',
    this.emptyMessage = 'Les données publiées apparaîtront ici dès leur validation.',
    this.emptyIcon = Icons.auto_awesome_mosaic_outlined,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.skeletonType = AdpSkeletonType.list,
    this.customSkeleton,
  });

  final bool isLoading;
  final bool hasError;
  final bool isEmpty;
  final T? data;
  final Widget Function(BuildContext context, T data) contentBuilder;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final AdpSkeletonType skeletonType;
  final Widget? customSkeleton;

  @override
  Widget build(BuildContext context) {
    if (isLoading && data == null) {
      return AdpSoftReveal(child: customSkeleton ?? _buildSkeleton(skeletonType));
    }

    if (hasError && data == null) {
      return AdpSoftReveal(
        child: AdpErrorState(
          message: errorMessage ?? 'Impossible de charger les informations.',
          onRetry: onRetry,
        ),
      );
    }

    if (isEmpty || data == null) {
      return AdpSoftReveal(
        child: AdpEmptyState(
          title: emptyTitle,
          message: emptyMessage,
          icon: emptyIcon,
          actionLabel: emptyActionLabel,
          onAction: onEmptyAction,
        ),
      );
    }

    return AdpSoftReveal(child: contentBuilder(context, data as T));
  }

  Widget _buildSkeleton(AdpSkeletonType type) {
    switch (type) {
      case AdpSkeletonType.projectCard:
        return const AdpSkeletonProjectList();
      case AdpSkeletonType.card:
        return const AdpSkeletonCardList();
      case AdpSkeletonType.profile:
        return const AdpSkeletonProfile();
      case AdpSkeletonType.list:
        return const AdpSkeletonList();
    }
  }
}

enum AdpSkeletonType { list, card, projectCard, profile }

// ─────────────────────────────────────────────
// SKELETON EFFECT ENGINE (Animated Wave Shimmer)
// ─────────────────────────────────────────────

class AdpShimmer extends StatefulWidget {
  const AdpShimmer({super.key, required this.child});
  final Widget child;

  @override
  State<AdpShimmer> createState() => _AdpShimmerState();
}

class _AdpShimmerState extends State<AdpShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: const [
                Color(0xFFEBE6DD),
                Color(0xFFF7F5F0),
                Color(0xFFEBE6DD),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class AdpSkeletonBox extends StatelessWidget {
  const AdpSkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E0D8),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class AdpSkeletonList extends StatelessWidget {
  const AdpSkeletonList({super.key, this.itemCount = 4});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AdpShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdpColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  AdpSkeletonBox(width: 36, height: 36, borderRadius: 10),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdpSkeletonBox(width: 140, height: 14),
                        SizedBox(height: 6),
                        AdpSkeletonBox(width: 90, height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const AdpSkeletonBox(height: 12),
              const SizedBox(height: 6),
              const AdpSkeletonBox(width: 200, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class AdpSkeletonProjectList extends StatelessWidget {
  const AdpSkeletonProjectList({super.key, this.itemCount = 3});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AdpShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AdpColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                color: const Color(0xFFE2DDD5),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    AdpSkeletonBox(width: 70, height: 18, borderRadius: 6),
                    AdpSkeletonBox(width: 40, height: 16, borderRadius: 10),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AdpSkeletonBox(width: 220, height: 18),
                    SizedBox(height: 8),
                    AdpSkeletonBox(height: 13),
                    SizedBox(height: 6),
                    AdpSkeletonBox(width: 160, height: 13),
                    SizedBox(height: 16),
                    AdpSkeletonBox(height: 8, borderRadius: 4),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AdpSkeletonBox(width: 80, height: 14),
                        AdpSkeletonBox(width: 100, height: 14),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AdpSkeletonBox(width: 90, height: 14),
                        AdpSkeletonBox(width: 100, height: 32, borderRadius: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdpSkeletonCardList extends StatelessWidget {
  const AdpSkeletonCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdpSkeletonList(itemCount: 3);
  }
}

class AdpSkeletonProfile extends StatelessWidget {
  const AdpSkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return AdpShimmer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            AdpSkeletonBox(width: 76, height: 76, borderRadius: 38),
            SizedBox(height: 14),
            AdpSkeletonBox(width: 160, height: 20),
            SizedBox(height: 8),
            AdpSkeletonBox(width: 120, height: 14),
            SizedBox(height: 24),
            AdpSkeletonBox(height: 80, borderRadius: 18),
            SizedBox(height: 16),
            AdpSkeletonBox(height: 140, borderRadius: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE (Culturally Rooted & Welcoming)
// ─────────────────────────────────────────────

class AdpEmptyState extends StatelessWidget {
  const AdpEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFE6),
                shape: BoxShape.circle,
                border: Border.all(color: AdpColors.border),
              ),
              child: Center(
                child: Icon(icon, color: AdpColors.terracotta, size: 32),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AdpColors.ink,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AdpColors.muted,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdpColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: onAction,
                child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ERROR STATE (Human, Calm & Actionable)
// ─────────────────────────────────────────────

class AdpErrorState extends StatelessWidget {
  const AdpErrorState({
    super.key,
    this.title = 'Connexion interrompue',
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFED7AA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.wifi_off_rounded, color: AdpColors.terracotta, size: 26),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AdpColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AdpColors.muted,
                  height: 1.4,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdpColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Backward-compatibility aliases
class AppLoading extends StatelessWidget {
  const AppLoading({super.key});
  @override
  Widget build(BuildContext context) => const AdpSkeletonList(itemCount: 3);
}

class AppMessage extends StatelessWidget {
  const AppMessage({super.key, required this.title, required this.message, this.onRetry});
  final String title;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => AdpEmptyState(
        title: title,
        message: message,
        actionLabel: onRetry != null ? 'Réessayer' : null,
        onAction: onRetry,
      );
}
