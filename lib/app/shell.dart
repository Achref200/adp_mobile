import 'dart:ui';
import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AdpColors.canvas,
        body: shell,
        bottomNavigationBar: _StudioBottomNav(
          currentIndex: shell.currentIndex,
          onTap: (index) => shell.goBranch(index,
              initialLocation: index == shell.currentIndex),
        ),
      );
}

// ── Studio-Identical Bottom Navigation Dock ──
// Matches frontend/css/components.css .bottom-nav exactly
class _StudioBottomNav extends StatelessWidget {
  const _StudioBottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItemData(label: 'Accueil', activeIcon: Icons.home_rounded, inactiveIcon: Icons.home_outlined),
    _NavItemData(label: 'Projets', activeIcon: Icons.eco_rounded, inactiveIcon: Icons.eco_outlined),
    _NavItemData(label: 'e-Pass', activeIcon: Icons.badge_rounded, inactiveIcon: Icons.badge_outlined),
    _NavItemData(label: 'Profil', activeIcon: Icons.person_rounded, inactiveIcon: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F5).withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(color: AdpColors.ink.withValues(alpha: 0.08), width: 1),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 0, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                return _NavItem(
                  data: _items[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.label, required this.activeIcon, required this.inactiveIcon});
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.data, required this.isActive, required this.onTap});
  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, isActive ? -1 : 0, 0),
              child: Icon(
                isActive ? data.activeIcon : data.inactiveIcon,
                size: 22,
                color: isActive ? AdpColors.ink : AdpColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: isActive ? AdpColors.ink : AdpColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            // Terracotta active indicator bar (14px × 2.5px)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: isActive ? 14 : 0,
              height: 2.5,
              decoration: BoxDecoration(
                color: AdpColors.terracotta,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
