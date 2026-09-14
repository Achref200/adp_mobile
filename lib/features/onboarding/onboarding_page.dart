import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Official ADP Logo — Interlocking Teal↔Green Infinity/Diamond (mini version)
class _AdpInfinityPainterMini extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final lw = w * 0.30;
    final lh = h * 0.42;
    final rCorner = w * 0.13;
    final gap = w * 0.055;

    Path roundedRect(double x, double y, double ww, double hh, double rr) {
      final p = Path();
      p.moveTo(x + rr, y);
      p.lineTo(x + ww - rr, y);
      p.quadraticBezierTo(x + ww, y, x + ww, y + rr);
      p.lineTo(x + ww, y + hh - rr);
      p.quadraticBezierTo(x + ww, y + hh, x + ww - rr, y + hh);
      p.lineTo(x + rr, y + hh);
      p.quadraticBezierTo(x, y + hh, x, y + hh - rr);
      p.lineTo(x, y + rr);
      p.quadraticBezierTo(x, y, x + rr, y);
      p.close();
      return p;
    }

    // Teal lobe (top-right) — solid brand color
    final rx1 = cx + gap * 0.45;
    final ry1 = cy - gap * 0.45;
    canvas.drawPath(
      roundedRect(rx1 - lw, ry1 - lh, lw * 2, lh * 2, rCorner),
      Paint()
        ..color = const Color(0xFF00A8A4)
        ..style = PaintingStyle.fill,
    );

    // Green lobe (bottom-left) — solid brand color
    final rx2 = cx - gap * 0.45;
    final ry2 = cy + gap * 0.45;
    canvas.drawPath(
      roundedRect(rx2 - lw, ry2 - lh, lw * 2, lh * 2, rCorner),
      Paint()
        ..color = const Color(0xFF7CCB4A)
        ..style = PaintingStyle.fill,
    );

    // Interlock bridges — solid colors
    final bridgeW = w * 0.10;
    final bridgeH = h * 0.03;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - gap * 0.5), width: bridgeW, height: bridgeH),
      Paint()
        ..color = const Color(0xFF00A8A4)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + gap * 0.5), width: bridgeW, height: bridgeH),
      Paint()
        ..color = const Color(0xFF7CCB4A)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 1;
  String _connection = 'diaspora';
  final Set<String> _priorities = {'Patrimoine UNESCO & Menzeh', 'Littoral & Zéro Déchet'};
  String _path = 'member';

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      _complete();
    }
  }

  void _prev() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.go('/splash');
    }
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('user_connection', _connection);
    await prefs.setString('user_tier', _path);
    if (mounted) context.go('/auth/login');
  }

  String get _buttonText {
    switch (_step) {
      case 1:
        return 'Continuer';
      case 2:
        return 'Valider mes priorités (${_priorities.length})';
      case 3:
        return 'Générer mon profil';
      case 4:
        return 'Entrer dans l\'application';
      default:
        return 'Continuer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdpColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar: Back · Logo · Step Indicators · Passer ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  _CircleIconBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: _prev,
                  ),
                  const SizedBox(width: 14),
                  // Official ADP logo mark in top bar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AdpColors.surface,
                      border: Border.all(
                        color: AdpColors.ink.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: CustomPaint(
                      size: const Size(20, 20),
                      painter: _AdpInfinityPainterMini(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 4-segment step bar
                  Expanded(
                    child: Row(
                      children: List.generate(4, (i) {
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            height: 3.5,
                            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                            decoration: BoxDecoration(
                              color: i < _step
                                  ? AdpColors.ink
                                  : AdpColors.ink.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 14),
                  if (_step < 4)
                    GestureDetector(
                      onTap: () => context.go('/auth/login'),
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AdpColors.muted,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 38),
                ],
              ),
            ),

            // ── Step Content ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: _buildStep(),
                  ),
                ),
              ),
            ),

            // ── Bottom Action ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AdpColors.ink,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                        textStyle: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      onPressed: _next,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_buttonText),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                  if (_step == 4) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdpColors.ink,
                          side: BorderSide(
                              color: AdpColors.ink.withValues(alpha: 0.08)),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => context.go('/auth/login'),
                        child: const Text(
                            'Se connecter avec un autre compte'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Origine ──
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepLabel(text: 'Étape 1 sur 4 · Origine'),
        const SizedBox(height: 8),
        Text(
          'Quel est votre lien\navec Djerba ?',
          style: GoogleFonts.barlowCondensed(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: AdpColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pour connecter votre profil à la communauté qui vous correspond.',
          style: TextStyle(fontSize: 14, color: AdpColors.muted, height: 1.5),
        ),
        const SizedBox(height: 20),
        _ChoiceCard(
          title: 'Diaspora djerbienne',
          subtitle: 'En France, Europe ou ailleurs dans le monde',
          icon: Icons.public_rounded,
          iconColor: AdpColors.ocean,
          isSelected: _connection == 'diaspora',
          onTap: () => setState(() => _connection = 'diaspora'),
        ),
        const SizedBox(height: 10),
        _ChoiceCard(
          title: 'Résident ou Originaire de l\'île',
          subtitle: 'Houmt Souk, Midoun, Ajim, Guellala...',
          icon: Icons.home_rounded,
          iconColor: AdpColors.terracotta,
          isSelected: _connection == 'resident',
          onTap: () => setState(() => _connection = 'resident'),
        ),
        const SizedBox(height: 10),
        _ChoiceCard(
          title: 'Ami & Amoureux de Djerba',
          subtitle: 'Attaché au patrimoine et aux habitants',
          icon: Icons.favorite_rounded,
          iconColor: const Color(0xFF10B981),
          isSelected: _connection == 'friend',
          onTap: () => setState(() => _connection = 'friend'),
        ),
      ],
    );
  }

  // ── Step 2: Priorités ──
  Widget _buildStep2() {
    const causes = [
      'Patrimoine UNESCO & Menzeh',
      'Littoral & Zéro Déchet',
      'FabLab & Jeunesse Midoun',
      'Fours Solaires Guellala',
      'Santé & Hôpital Insulaire',
      'Dessalement Solaire',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepLabel(text: 'Étape 2 sur 4 · Priorités'),
        const SizedBox(height: 8),
        Text(
          'Quelles causes vous tiennent à cœur ?',
          style: GoogleFonts.barlowCondensed(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: AdpColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sélectionnez les projets que vous souhaitez voir progresser.',
          style: TextStyle(fontSize: 14, color: AdpColors.muted, height: 1.5),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: causes.map((cause) {
            final isActive = _priorities.contains(cause);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isActive) {
                    _priorities.remove(cause);
                  } else {
                    _priorities.add(cause);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? AdpColors.ink : AdpColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive
                        ? AdpColors.ink
                        : AdpColors.ink.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? Icons.check : Icons.eco_outlined,
                      size: 13,
                      color: isActive ? Colors.white : AdpColors.ocean,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cause,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AdpColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Guarantee Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AdpColors.canvasSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AdpColors.ink.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
                const Icon(Icons.check_circle_outline_rounded,
                  size: 18, color: AdpColors.ocean),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '100% des dons ADP vont directement aux projets validés par l\'AG.',
                  style: TextStyle(
                      fontSize: 12.5, color: AdpColors.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3: Engagement ──
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepLabel(text: 'Étape 3 sur 4 · Engagement'),
        const SizedBox(height: 8),
        Text(
          'Comment souhaitez-vous agir ?',
          style: GoogleFonts.barlowCondensed(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: AdpColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Deux statuts transparents définis par la charte ADP.',
          style: TextStyle(fontSize: 14, color: AdpColors.muted, height: 1.5),
        ),
        const SizedBox(height: 20),
        // Adhérent Actif
        _TierCard(
          isSelected: _path == 'member',
          onTap: () => setState(() => _path = 'member'),
          badgeText: 'OFFICIEL',
          badgeColor: AdpColors.ocean,
          badgeBgColor: AdpColors.oceanSoft,
          recommended: true,
          title: 'Adhérent Actif ADP',
          description:
              'Droit de vote à l\'AG, carte e-Pass digitale, accès aux commissions de projets.',
        ),
        const SizedBox(height: 12),
        // Sympathisant
        _TierCard(
          isSelected: _path == 'sympathisant',
          onTap: () => setState(() => _path = 'sympathisant'),
          badgeText: 'ACCÈS LIBRE',
          badgeColor: AdpColors.ink,
          badgeBgColor: AdpColors.ink.withValues(alpha: 0.06),
          recommended: false,
          title: 'Sympathisant',
          description:
              'Suivi transparent des actualités, dons libres, invitations aux événements ouverts.',
        ),
      ],
    );
  }

  // ── Step 4: e-Pass Digital Preview ──
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 14, color: AdpColors.success),
            const SizedBox(width: 4),
            Text(
              'Prêt pour Djerba',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AdpColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Votre e-Pass digital\nest prêt',
          textAlign: TextAlign.center,
          style: GoogleFonts.barlowCondensed(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: AdpColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Votre identifiant officiel au sein de la communauté.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AdpColors.muted, height: 1.5),
        ),
        const SizedBox(height: 24),
        // ── Digital e-Pass Card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0E2129),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0E2129),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.explore_rounded,
                          size: 22, color: AdpColors.sandGold),
                      const SizedBox(width: 8),
                      Text(
                        'ADP DJERBA',
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '2026',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Titulaire
              Text(
                'Titulaire',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Membre ADP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ADP-DJB-2026-0001',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AdpColors.sandGold,
                ),
              ),
              const SizedBox(height: 14),
              // Bottom Row
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIEN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _connection == 'diaspora'
                              ? 'Diaspora Europe'
                              : _connection == 'resident'
                                  ? 'Résident Djerba'
                                  : 'Ami de Djerba',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 12, color: Color(0xFF6EE7B7)),
                        const SizedBox(width: 4),
                        const Text(
                          'ACTIF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6EE7B7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Reusable Widgets ──

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AdpColors.terracotta,
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AdpColors.surface,
          border: Border.all(color: AdpColors.ink.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 16, color: AdpColors.ink),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: AdpColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AdpColors.ink : AdpColors.ink.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AdpColors.ink.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AdpColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Radio check circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AdpColors.ink : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AdpColors.ink
                      : AdpColors.mutedLight,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.isSelected,
    required this.onTap,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBgColor,
    required this.recommended,
    required this.title,
    required this.description,
  });
  final bool isSelected;
  final VoidCallback onTap;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBgColor;
  final bool recommended;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: AdpColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AdpColors.ink : AdpColors.ink.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AdpColors.ink.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'Recommandé',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AdpColors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AdpColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdpColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Radio check circle
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AdpColors.ink : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AdpColors.ink
                      : AdpColors.mutedLight,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
