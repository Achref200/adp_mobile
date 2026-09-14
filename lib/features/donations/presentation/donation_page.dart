import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/widgets/adp_feedback.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/donations/presentation/donation_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key, this.projectId, this.projectName});
  final String? projectId;
  final String? projectName;

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  double _amount = 50;
  bool _monthly = false;
  bool _anonymous = false;
  final List<int> _presets = [20, 50, 100, 250, 500];

  double get _taxDeduction => _amount * 0.66;
  double get _realCost => _amount - _taxDeduction;

  @override
  Widget build(BuildContext context) => BlocConsumer<DonationCubit, DonationState>(
        listenWhen: (previous, current) => previous.data != current.data || previous.message != current.message,
        listener: (context, state) async {
          if (state.data != null) {
            final opened = await launchUrl(state.data!, mode: LaunchMode.externalApplication);
            if (context.mounted && !opened) {
              AdpFeedback.failure(context,
                  source: 'Dons · Paiement',
                  message: 'Impossible d’ouvrir la page de paiement sécurisé.');
            }
            if (context.mounted) context.read<DonationCubit>().clearCheckout();
          }
          if (state.status == AsyncStatus.failure && context.mounted) {
            AdpFeedback.failure(context,
                source: 'Dons',
                message: state.message ?? 'Les dons sont temporairement indisponibles.');
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AdpColors.canvas,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const AdpStudioBackButton(),
            title: const Text(
              'Faire un don',
              style: TextStyle(fontWeight: FontWeight.w800, color: AdpColors.ink),
            ),
            iconTheme: const IconThemeData(color: AdpColors.ink),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // ── Frequency Pill Toggle (Frontend Studio Parity) ──
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AdpColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AdpColors.ink.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _monthly = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_monthly ? AdpColors.ink : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Text(
                            'Don ponctuel',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: !_monthly ? Colors.white : AdpColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _monthly = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _monthly ? AdpColors.ink : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Text(
                            'Don mensuel',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _monthly ? Colors.white : AdpColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Header Context ──
              Text(
                widget.projectName == null
                    ? 'Un geste qui devient impact.'
                    : 'Soutenir ${widget.projectName}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdpColors.ink, height: 1.15),
              ),
              const SizedBox(height: 6),
              const Text(
                'HelloAsso gère le paiement en toute sécurité. ADP ne collecte, ne voit et ne stocke jamais vos informations bancaires.',
                style: TextStyle(fontSize: 13, color: AdpColors.muted),
              ),
              const SizedBox(height: 20),

              // ── Amount Presets 6-Box Grid ──
              const Text(
                'MONTANT DU DON',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AdpColors.terracotta,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 16) / 3;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._presets.map((preset) {
                      final isSelected = _amount == preset;
                      return SizedBox(
                        width: itemWidth,
                        child: GestureDetector(
                          onTap: () => setState(() => _amount = preset.toDouble()),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AdpColors.ink : AdpColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AdpColors.ink : AdpColors.ink.withValues(alpha: 0.08),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? AdpColors.ink.withValues(alpha: 0.1) : AdpColors.ink.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '$preset €',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : AdpColors.ink,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    // "Autre" option
                    SizedBox(
                      width: itemWidth,
                      child: GestureDetector(
                        onTap: () async {
                          final controller = TextEditingController(text: _amount.toInt().toString());
                          final res = await showDialog<int>(
                            context: context,
                            builder: (dlgCtx) => AlertDialog(
                              title: const Text('Montant libre (€)'),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                decoration: const InputDecoration(hintText: 'Ex: 75', suffixText: '€'),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dlgCtx), child: const Text('Annuler')),
                                FilledButton(
                                  onPressed: () {
                                    final val = int.tryParse(controller.text);
                                    if (val != null && val > 0) Navigator.pop(dlgCtx, val);
                                  },
                                  child: const Text('Valider'),
                                ),
                              ],
                            ),
                          );
                          if (res != null) setState(() => _amount = res.toDouble());
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_presets.contains(_amount.toInt()) ? AdpColors.ink : AdpColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: !_presets.contains(_amount.toInt()) ? AdpColors.ink : AdpColors.ink.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            !_presets.contains(_amount.toInt()) ? '${_amount.toInt()} €' : 'Autre',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: !_presets.contains(_amount.toInt()) ? Colors.white : AdpColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),

              // ── Frontend Parity Tax Benefit Card ──
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AdpColors.canvasSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdpColors.ink.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdpColors.terracotta.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long_outlined, size: 20, color: AdpColors.terracotta),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ce don ne vous coûte que ${_realCost.toStringAsFixed(0)} €',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AdpColors.ink),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Après déduction fiscale de 66% pour les résidents en France',
                            style: TextStyle(fontSize: 11.5, color: AdpColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AdpColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: AdpColors.ink.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Big amount display
                    Text(
                      '${_amount.toInt()} €',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AdpColors.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _monthly ? 'par mois' : 'don unique',
                      style: const TextStyle(fontSize: 13, color: AdpColors.muted, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    // Deduction row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Déduction fiscale (66%)',
                          style: TextStyle(fontSize: 13, color: AdpColors.muted, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '-${_taxDeduction.toStringAsFixed(0)} €',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AdpColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Real cost row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Coût réel après impôts',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdpColors.ink),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdpColors.terracotta.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_realCost.toStringAsFixed(0)} €',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AdpColors.terracotta,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AdpColors.ink.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AdpColors.muted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Résidents fiscaux FR/UE · Art. 200 CGI',
                              style: TextStyle(
                                fontSize: 11,
                                color: AdpColors.muted.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Options (Monthly / Anonymous) ──
              Container(
                decoration: BoxDecoration(
                  color: AdpColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: _monthly,
                      onChanged: (value) => setState(() => _monthly = value),
                      title: const Text(
                        'Don mensuel récurrent',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdpColors.ink),
                      ),
                      subtitle: const Text(
                        'Géré par un formulaire HelloAsso hébergé.',
                        style: TextStyle(fontSize: 12, color: AdpColors.muted),
                      ),
                      activeTrackColor: AdpColors.ocean,
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: AdpColors.ink.withValues(alpha: 0.06)),
                    SwitchListTile.adaptive(
                      value: _anonymous,
                      onChanged: (value) => setState(() => _anonymous = value),
                      title: const Text(
                        'Don anonyme',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdpColors.ink),
                      ),
                      subtitle: const Text(
                        'Votre nom ne sera pas affiché publiquement.',
                        style: TextStyle(fontSize: 12, color: AdpColors.muted),
                      ),
                      activeTrackColor: AdpColors.ocean,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ── CTA Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdpColors.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: state.isLoading ? null : _continue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.isLoading) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Text('Préparation du paiement…', style: TextStyle(fontWeight: FontWeight.w700)),
                      ] else ...[
                        const Icon(Icons.open_in_new, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Continuer vers HelloAsso · ${_amount.toInt()} €',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Le paiement est confirmé par HelloAsso serveur-à-serveur. ADP met à jour automatiquement votre contribution.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AdpColors.muted),
              ),
            ],
          ),
        ),
      );

  void _continue() => context.read<DonationCubit>().beginCheckout(
        amountCents: _amount.toInt() * 100,
        frequency: _monthly ? DonationFrequency.monthly : DonationFrequency.oneOff,
        anonymous: _anonymous,
        projectId: widget.projectId,
      );
}
