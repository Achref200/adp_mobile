import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';

class AdpEyebrow extends StatelessWidget {
  const AdpEyebrow(
      {super.key, required this.text, this.color = AdpColors.terracotta});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 3, height: 18, color: color),
        const SizedBox(width: 9),
        Text(text.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color, letterSpacing: 1.4, fontWeight: FontWeight.w800))
      ]);
}

class AdpPrimaryButton extends StatelessWidget {
  const AdpPrimaryButton(
      {super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w800)));
}

class AdpEntrance extends StatefulWidget {
  const AdpEntrance(
      {super.key,
      required this.child,
      this.delay = Duration.zero,
      this.offset = const Offset(0, .06)});
  final Widget child;
  final Duration delay;
  final Offset offset;
  @override
  State<AdpEntrance> createState() => _AdpEntranceState();
}

class _AdpEntranceState extends State<AdpEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 540));
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      child: SlideTransition(
          position: Tween<Offset>(begin: widget.offset, end: Offset.zero)
              .animate(CurvedAnimation(
                  parent: _controller, curve: Curves.easeOutCubic)),
          child: widget.child));
}

class AdpSoftReveal extends StatelessWidget {
    const AdpSoftReveal({super.key, required this.child});
    final Widget child;

    @override
    Widget build(BuildContext context) {
        return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: child,
            builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                    offset: Offset(0, (1 - value) * 8),
                    child: child,
                ),
            ),
        );
    }
}

class AdpImpactMeter extends StatelessWidget {
  const AdpImpactMeter(
      {super.key,
      required this.now,
      required this.potential,
      required this.caption});
  final int now, potential;
  final String caption;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final width = (constraints.maxWidth - 36) / 2;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SizedBox(
                width: width,
                child: Text('$now',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800, color: AdpColors.muted))),
            const SizedBox(width: 36),
            SizedBox(
                width: width,
                child: Text('$potential',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AdpColors.terracotta)))
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
                width: width,
                height: 96,
                decoration: BoxDecoration(
                    color: AdpColors.navy.withValues(alpha: .12),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)))),
            const SizedBox(width: 36),
            Container(
                width: width,
                height: 164,
                decoration: const BoxDecoration(
                    color: AdpColors.terracotta,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))))
          ]),
          const SizedBox(height: 10),
          Text(caption,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AdpColors.muted))
        ]);
      });
}
