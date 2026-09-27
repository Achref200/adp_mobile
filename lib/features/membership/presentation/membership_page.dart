import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/widgets/adp_feedback.dart';
import 'package:adp_mobile/core/widgets/adp_haptic.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/epass/presentation/epass_cubit.dart';
import 'package:adp_mobile/features/membership/presentation/membership_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});
  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  int _step = 0;
  String _plan = 'diaspora';
  final _form = GlobalKey<FormState>();
  final _connection = TextEditingController();
  final _motivation = TextEditingController();
  /// Lightweight referral: just a free-text name field (e.g. "Wissem").
  /// Not prominent, not a code, not selecting a specific person — just info
  /// for the admin to understand how the member heard about ADP.
  final _referralName = TextEditingController();
  bool _showReferralHelp = false;
  static const _plans = {'individual': 3000, 'family': 5000, 'diaspora': 4000, 'benefactor': 10000};

  @override
  void dispose() {
    _connection.dispose();
    _motivation.dispose();
    _referralName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<MembershipCubit, MembershipState>(
        listenWhen: (previous, current) => previous.checkoutUrl != current.checkoutUrl || previous.message != current.message || previous.data?.status != current.data?.status,
        listener: (context, state) async {
          if (state.checkoutUrl != null) {
            final opened = await launchUrl(state.checkoutUrl!, mode: LaunchMode.externalApplication);
            if (context.mounted && !opened) _message('Impossible d’ouvrir le paiement sécurisé HelloAsso.');
            if (context.mounted) context.read<MembershipCubit>().clearCheckout();
          }
          if (state.status == AsyncStatus.failure && context.mounted) {
            AdpFeedback.failure(context,
                source: 'Adhésion',
                message: state.message ?? 'Cette action est indisponible.');
          }
          if (state.data?.status == MembershipStatus.submitted && context.mounted) {
            context.read<EPassCubit>().load();
            _message('Votre demande est enregistrée. Finalisez le paiement avec HelloAsso pour continuer.');
          }
        },
        builder: (context, state) {
          const titles = ['Votre lien avec Djerba', 'Formule d\'adhésion', 'Validation du dossier'];
          return Scaffold(
            backgroundColor: AdpColors.canvas,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const AdpStudioBackButton(),
              title: const Text('Adhésion & Cotisation'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(AdpSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / titles.length,
                      color: AdpColors.ocean,
                      backgroundColor: AdpColors.ink.withValues(alpha: 0.08),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    titles[_step],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AdpColors.ink),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: IndexedStack(index: _step, children: [_identity(), _plansView(), _summary(state)])),
                  Row(children: [
                    if (_step > 0)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdpColors.ink,
                          side: BorderSide(color: AdpColors.ink.withValues(alpha: 0.12)),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: state.isLoading ? null : () => setState(() => _step--),
                        child: const Text('Retour'),
                      ),
                    const Spacer(),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AdpColors.ink,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: state.isLoading ? null : () => _continue(state),
                      child: Text(_step == 2 ? _cta(state) : 'Continuer'),
                    ),
                  ]),
                ],
              ),
            ),
          );
        },
      );

  Widget _identity() => Form(
        key: _form,
        child: ListView(children: [
          const Text(
            'Partagez ce qui aide le comité à valider votre adhésion. Le paiement est ensuite sécurisé par HelloAsso.',
            style: TextStyle(fontSize: 13, color: AdpColors.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _connection,
            decoration: InputDecoration(
              labelText: 'Votre lien avec l\'île de Djerba',
              hintText: 'Ex: Originaire de Houmt Souk, passionné par le patrimoine...',
              fillColor: AdpColors.surface,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AdpColors.ink.withValues(alpha: 0.08))),
            ),
            validator: (value) => value == null || value.trim().length < 2 ? 'Veuillez préciser votre lien avec Djerba.' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _motivation,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Pourquoi souhaitez-vous rejoindre l\'association ? (optionnel)',
              hintText: 'Projets qui vous tiennent à cœur, compétences à partager...',
              fillColor: AdpColors.surface,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AdpColors.ink.withValues(alpha: 0.08))),
            ),
          ),
          const SizedBox(height: 14),
          // ── Lightweight referral info (free text, non-prominent) ──
          InkWell(
            onTap: () => setState(() => _showReferralHelp = !_showReferralHelp),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AdpColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _referralName.text.trim().isNotEmpty
                      ? AdpColors.tealDeep.withValues(alpha: 0.2)
                      : AdpColors.ink.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      size: 16, color: AdpColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Qui vous a parlé de l\'ADP ? (optionnel)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AdpColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(_referralName.text.trim().isNotEmpty
                      ? _referralName.text.trim()
                      : 'Ajouter un nom…',
                      style: TextStyle(
                        fontSize: 12,
                        color: _referralName.text.trim().isNotEmpty
                            ? AdpColors.tealDeep
                            : AdpColors.mutedLight,
                        fontWeight: FontWeight.w600,
                      ),
                  ),
                ],
              ),
            ),
          ),
          if (_showReferralHelp) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdpColors.canvasSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdpColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ce champ est juste une information pour le bureau ADP. '
                    'Il n\'y a pas de code ni de sélection de personne — '
                    'vous pouvez simplement écrire un nom ou laisser vide.',
                    style: TextStyle(fontSize: 11.5, color: AdpColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _referralName,
                    decoration: InputDecoration(
                      hintText: 'Ex: Wissem, Achref, la page Facebook ADP…',
                      hintStyle: const TextStyle(color: AdpColors.mutedLight, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AdpColors.ink.withValues(alpha: 0.08)),
                      ),
                      filled: true,
                      fillColor: AdpColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => setState(() => _showReferralHelp = false),
                  ),
                ],
              ),
            ),
          ],
        ]),
      );

  Widget _plansView() => ListView(
        children: _plans.entries
            .map((entry) {
              final isSelected = _plan == entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AdpColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AdpColors.ocean : AdpColors.ink.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? AdpColors.ocean.withValues(alpha: 0.06) : AdpColors.ink.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () => setState(() => _plan = entry.key),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AdpColors.ocean : AdpColors.muted,
                  ),
                  title: Text(
                    _label(entry.key),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AdpColors.ink),
                  ),
                  subtitle: Text(
                    '${(entry.value / 100).toStringAsFixed(0)} € / an · Cotisation annuelle',
                    style: const TextStyle(fontSize: 12.5, color: AdpColors.muted),
                  ),
                ),
              );
            })
            .toList(),
      );

  Widget _summary(MembershipState state) => ListView(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdpColors.canvasSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: AdpColors.ocean, size: 20),
                  SizedBox(width: 8),
                  Text('Processus officiel d\'adhésion', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Après confirmation du paiement par HelloAsso, le bureau de l\'ADP effectue une validation statutaire pour activer votre e-Pass membre certifié.',
                style: TextStyle(fontSize: 12.5, color: AdpColors.muted, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AdpColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdpColors.ink.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              ListTile(title: const Text('Formule sélectionnée'), trailing: Text(_label(_plan), style: const TextStyle(fontWeight: FontWeight.w800))),
              Divider(height: 1, color: AdpColors.ink.withValues(alpha: 0.06)),
              ListTile(title: const Text('Montant de la cotisation'), trailing: Text('${(_plans[_plan]! / 100).toStringAsFixed(0)} €', style: const TextStyle(fontWeight: FontWeight.w800, color: AdpColors.ocean, fontSize: 16))),
              if (_referralName.text.trim().isNotEmpty) ...[
                Divider(height: 1, color: AdpColors.ink.withValues(alpha: 0.06)),
                ListTile(
                  title: const Text('Référence (info bureau)'),
                  trailing: Text(_referralName.text.trim(), style: const TextStyle(fontWeight: FontWeight.w600, color: AdpColors.muted, fontSize: 13)),
                  subtitle: const Text('Juste une indication pour le bureau ADP', style: TextStyle(fontSize: 10.5, color: AdpColors.mutedLight)),
                ),
              ],
              Divider(height: 1, color: AdpColors.ink.withValues(alpha: 0.06)),
              const ListTile(title: Text('Cycle d\'activation'), subtitle: Text('Paiement HelloAsso → Examen bureau → e-Pass actif')),
            ],
          ),
        ),
        if (state.data?.status == MembershipStatus.submitted)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'Votre dossier a bien été enregistré. Le règlement de la cotisation est nécessaire pour finaliser.',
              style: TextStyle(color: AdpColors.terracotta, fontWeight: FontWeight.w700),
            ),
          ),
      ]);

  String _cta(MembershipState state) => state.data?.status == MembershipStatus.submitted ? 'Payer en toute sécurité avec HelloAsso' : 'Valider et continuer';

  void _continue(MembershipState state) {
    if (_step == 0) {
      if (_form.currentState!.validate()) setState(() => _step++);
      return;
    }
    if (_step == 1) {
      setState(() => _step++);
      return;
    }
    if (state.data?.status == MembershipStatus.submitted) {
      context.read<MembershipCubit>().beginCheckout();
      return;
    }
    context.read<MembershipCubit>().submit(MembershipSubmission(
      plan: _plan,
      amountCents: _plans[_plan]!,
      djerbaConnection: _connection.text.trim(),
      motivation: _motivation.text.trim().isEmpty ? null : _motivation.text.trim(),
      referralCode: _referralName.text.trim().isEmpty ? null : _referralName.text.trim(),
    ));
  }

  String _label(String plan) => switch (plan) {
    'individual' => 'Membre Individuel',
    'family' => 'Membre Famille',
    'diaspora' => 'Membre Diaspora',
    _ => 'Membre Bienfaiteur',
  };
  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
}
