import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _anim,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _anim.forward();
    _autoAdvance();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _autoAdvance() async {
    await Future<void>.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final cubit = context.read<AuthCubit>();
    if (cubit.state.status == AuthStatus.unknown) await cubit.restore();
    if (!mounted) return;
    final target = cubit.state.status == AuthStatus.authenticated
        ? '/home'
        : (prefs.getBool('onboarding_complete') == true
            ? '/auth/login'
            : '/onboarding');
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  // ── Top Cultural Greeting Badge ──
                  const SizedBox(height: 18),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EDE4),
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(color: const Color(0xFFE2DDD3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'مرحباً بك',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AdpColors.terracotta,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '·   BIENVENUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AdpColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Center Architectural Emblem & Narrative ──
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF7EFE4),
                        border: Border.all(
                            color: const Color(0xFFEADBCE), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AdpColors.ink.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(84, 84),
                          painter: _DjerbaDomePainter(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'ASSOCIATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      color: AdpColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DJERBA PROJECT',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      height: 1.05,
                      color: AdpColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: const Text(
                      '« L\'île que nous chérissons, l\'avenir que nous bâtissons ensemble. »',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        color: AdpColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // ── Bottom Roots & Action ──
                  Container(
                    width: 32,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AdpColors.sandGold,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'INITIATIVE CITOYENNE DE LA DIASPORA',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AdpColors.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AdpColors.ink,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () => context.go('/onboarding'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Découvrir'),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AdpColors.ink,
                              side: BorderSide(
                                  color: AdpColors.ink.withValues(alpha: 0.08)),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () => context.go('/auth/login'),
                            child: const Text('Se connecter'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Handcrafted Architectural Djerbian Archway, Sun, Sea, and Amphora
class _DjerbaDomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Archway (dark ink)
    final archPath = Path();
    const archLeftFrac = 0.28;
    const archRightFrac = 0.72;
    const archBottomFrac = 0.82;
    final archLeft = w * archLeftFrac;
    final archRight = w * archRightFrac;
    final archBottom = h * archBottomFrac;
    final archTopY = h * 0.46;
    final archRadius = (archRight - archLeft) / 2;

    archPath.moveTo(archLeft, archBottom);
    archPath.lineTo(archLeft, archTopY);
    archPath.arcToPoint(
      Offset(archRight, archTopY),
      radius: Radius.circular(archRadius),
      clockwise: true,
    );
    archPath.lineTo(archRight, archBottom);
    archPath.close();

    canvas.drawPath(
        archPath,
        Paint()
          ..color = const Color(0xFF0E2129)
          ..style = PaintingStyle.fill);

    // Rising Golden Sun
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      14,
      Paint()
        ..color = const Color(0xFFD5AB72)
        ..style = PaintingStyle.fill,
    );

    // Sea Water
    canvas.save();
    canvas.clipPath(archPath);
    canvas.drawRect(
      Rect.fromLTRB(archLeft, h * 0.64, archRight, archBottom),
      Paint()
        ..color = const Color(0xFF0D6274)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // Clay Finial (amphora pot on top)
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.20),
      4.5,
      Paint()
        ..color = const Color(0xFFD46238)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
