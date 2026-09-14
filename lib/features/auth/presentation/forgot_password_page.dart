import 'package:adp_mobile/core/network/api_client.dart';
import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

const _useMockData = bool.fromEnvironment('ADP_USE_MOCK', defaultValue: false);

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdpColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/auth/login');
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEADBCE)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF0E2129)),
                ),
              ),
              const SizedBox(height: 32),

              // Title & Subtitle
              Text(
                'Réinitialisation',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: const Color(0xFF0E2129),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Indiquez votre email pour recevoir les instructions.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              if (_sent) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2DDD3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, size: 48, color: Color(0xFF0D6274)),
                      const SizedBox(height: 14),
                      Text(
                        'Lien envoyé par email',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0E2129)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Vérifiez vos courriers indésirables si vous ne recevez rien d\'ici quelques minutes.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E2129),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    onPressed: () => context.go('/auth/login'),
                    child: Text('Retour à la connexion', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ] else ...[
                Text(
                  'Email',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0E2129)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0E2129)),
                  decoration: InputDecoration(
                    hintText: 'nom@exemple.com',
                    hintStyle: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2DDD3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0E2129), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E2129),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Envoyer le lien', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14.5)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty) return;
    setState(() => _loading = true);
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() { _sent = true; _loading = false; });
      return;
    }
    try {
      await ApiClient().post('/v1/auth/forgot-password', data: {'email': _email.text.trim()});
    } catch (_) {}
    if (mounted) setState(() { _sent = true; _loading = false; });
  }
}
