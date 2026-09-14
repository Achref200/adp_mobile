import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/widgets/adp_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _country = TextEditingController(text: 'Tunisie');
  final _connection = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _country, _connection, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
        } else if (state.status == AuthStatus.failure) {
          AdpFeedback.failure(
            context,
            source: 'Inscription',
            message: state.message ?? 'Vérifiez les informations saisies et réessayez.',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AdpColors.canvas,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                            child: const Icon(Icons.arrow_back_rounded, size: 18, color: AdpColors.ink),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2DDD3).withValues(alpha: 0.5),
                            border: Border.all(color: const Color(0xFFE2DDD3)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ADHÉSION',
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: const Color(0xFF0E2129),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Headlines
                    Text(
                      'Rejoindre l\'ADP',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: const Color(0xFF0E2129),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Faites entendre votre voix pour le développement de l\'île.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Prénom',
                            controller: _first,
                            hint: 'Slim',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFormField(
                            label: 'Nom',
                            controller: _last,
                            hint: 'Ben Amor',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Email
                    _buildFormField(
                      label: 'Email',
                      controller: _email,
                      hint: 'slim@exemple.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'Email valide requis' : null,
                    ),
                    const SizedBox(height: 14),

                    // Residence
                    _buildFormField(
                      label: 'Résidence',
                      controller: _country,
                      hint: 'Tunisie, France...',
                      prefixIcon: Icons.public_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 14),

                    // Lien avec Djerba
                    _buildFormField(
                      label: 'Lien avec Djerba',
                      controller: _connection,
                      hint: 'Origine familiale, habitant, projet...',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),

                    // Mot de passe
                    _buildFormField(
                      label: 'Mot de passe',
                      controller: _password,
                      hint: 'Au moins 12 caractères',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      suffixWidget: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) => v == null || v.length < 12 ? '12 caractères minimum.' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD46238),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: state.status == AuthStatus.loading ? null : _submit,
                        child: state.status == AuthStatus.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Finaliser mon inscription',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check_rounded, size: 16),
                                ],
                              ),
                      ),
                    ),

                    if (state.status == AuthStatus.failure) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          state.message ?? 'Erreur lors de l\'inscription',
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Login Link
                    Center(
                      child: InkWell(
                        onTap: () => context.go('/auth/login'),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
                            children: [
                              const TextSpan(text: 'Déjà inscrit ? '),
                              TextSpan(
                                text: 'Se connecter',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0E2129),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    bool obscureText = false,
    Widget? suffixWidget,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0E2129),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0E2129)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF9CA3AF)),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: AdpColors.mutedLight) : null,
            suffixIcon: suffixWidget,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AdpColors.ink.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AdpColors.ink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AdpColors.terracotta),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AdpColors.terracotta, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_form.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        email: _email.text.trim(),
        country: _country.text.trim(),
        password: _password.text,
      );
    }
  }
}
