import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/widgets/adp_feedback.dart';
import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'slim.benamor@djerba.tn');
  final _password = TextEditingController(text: 'Password123!');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/home');
          } else if (state.status == AuthStatus.failure) {
            AdpFeedback.failure(
              context,
              source: 'Connexion',
              message: state.message ?? 'Vérifiez vos identifiants et réessayez.',
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AdpColors.canvas,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Top Bar ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleBackBtn(onTap: () => Navigator.of(context).maybePop()),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: AdpColors.ink.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'ESPACE MEMBRE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: AdpColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Form Content ──
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Bon retour\nparmi nous',
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              color: AdpColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Connectez-vous pour retrouver votre e-Pass et vos contributions.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AdpColors.muted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AdpColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v != null && v.contains('@')
                                      ? null
                                      : 'Entrez un e-mail valide.',
                                  style: const TextStyle(fontSize: 14, color: AdpColors.ink),
                                  decoration: InputDecoration(
                                    hintText: 'nom@exemple.com',
                                    hintStyle: const TextStyle(color: AdpColors.mutedLight),
                                    prefixIcon: const Icon(Icons.mail_outline_rounded,
                                        size: 18, color: AdpColors.muted),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 13),
                                    filled: true,
                                    fillColor: AdpColors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: AdpColors.ink.withValues(alpha: 0.08),
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: AdpColors.ink.withValues(alpha: 0.08),
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: AdpColors.ink, width: 1.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Mot de passe',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AdpColors.ink,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          context.push('/auth/forgot-password'),
                                      child: const Text(
                                        'Oublié ?',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AdpColors.muted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  validator: (v) => v != null && v.length >= 8
                                      ? null
                                      : '8 caractères minimum.',
                                  style: const TextStyle(fontSize: 14, color: AdpColors.ink),
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: const TextStyle(color: AdpColors.mutedLight),
                                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                                        size: 18, color: AdpColors.muted),
                                    suffixIcon: GestureDetector(
                                      onTap: () =>
                                          setState(() => _obscure = !_obscure),
                                        child: Icon(
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 18,
                                        color: AdpColors.muted,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 13),
                                    filled: true,
                                    fillColor: AdpColors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: AdpColors.ink.withValues(alpha: 0.08),
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: AdpColors.ink.withValues(alpha: 0.08),
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: AdpColors.ink, width: 1.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Login Button
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
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    onPressed: state.status == AuthStatus.loading
                                        ? null
                                        : _submit,
                                    child: state.status == AuthStatus.loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text('Se connecter'),
                                              SizedBox(width: 8),
                                                Icon(Icons.arrow_forward,
                                                  size: 16),
                                            ],
                                          ),
                                  ),
                                ),

                                if (state.status == AuthStatus.failure) ...[
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      state.message ?? 'Connexion impossible.',
                                      style: const TextStyle(
                                        color: AdpColors.terracotta,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 20),
                                Center(
                                  child: GestureDetector(
                                    onTap: () =>
                                        context.push('/auth/register'),
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AdpColors.ink),
                                        children: [
                                          TextSpan(text: 'Nouveau sur ADP ? '),
                                          TextSpan(
                                            text: 'Créer un compte',
                                            style: TextStyle(
                                                color: AdpColors.terracotta),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      );

  void _submit() {
    if (_form.currentState!.validate()) {
      context
          .read<AuthCubit>()
          .login(email: _email.text.trim(), password: _password.text);
    }
  }
}

class _CircleBackBtn extends StatelessWidget {
  const _CircleBackBtn({required this.onTap});
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
        child: const Icon(Icons.arrow_back_rounded, size: 16, color: AdpColors.ink),
      ),
    );
  }
}
