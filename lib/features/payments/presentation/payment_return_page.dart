import 'package:adp_mobile/core/design/adp_components.dart';
import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/payments/presentation/payment_status_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PaymentReturnPage extends StatefulWidget {
  const PaymentReturnPage({super.key, this.checkoutIntentId, this.providerCode});
  final String? checkoutIntentId;
  final String? providerCode;

  @override
  State<PaymentReturnPage> createState() => _PaymentReturnPageState();
}

class _PaymentReturnPageState extends State<PaymentReturnPage> {
  @override
  void initState() {
    super.initState();
    final checkoutIntentId = widget.checkoutIntentId;
    if (checkoutIntentId != null && checkoutIntentId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PaymentStatusCubit>().verify(checkoutIntentId));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<PaymentStatusCubit, AsyncState<CheckoutVerification>>(
              builder: (context, state) {
                final hasIntent = widget.checkoutIntentId?.isNotEmpty == true;
                final confirmed = state.data?.confirmed == true;
                final title = confirmed ? 'Paiement confirmé' : hasIntent ? 'Vérification du paiement' : 'Retour de paiement reçu';
                final message = confirmed
                    ? 'HelloAsso a confirmé le paiement avec l’ADP. Le statut de votre adhésion ou de votre don est à jour.'
                    : hasIntent
                        ? 'Cette page de retour ne suffit pas à confirmer le paiement. L’ADP vérifie la transaction avec HelloAsso avant toute mise à jour.'
                        : 'Revenez dans l’application pour consulter le statut actuel de votre adhésion ou de votre don.';
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Spacer(),
                  Icon(confirmed ? Icons.check_circle_outline_rounded : Icons.shield_outlined, color: confirmed ? AdpColors.ocean : AdpColors.terracotta, size: 48),
                  const SizedBox(height: 24),
                  Text(title, style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 14),
                  Text(message, style: Theme.of(context).textTheme.titleMedium),
                  if (state.isLoading) ...[const SizedBox(height: 20), const LinearProgressIndicator()],
                  if (state.status == AsyncStatus.failure) ...[
                    const SizedBox(height: 20),
                    Text(state.message ?? 'Réessayez depuis votre profil dans quelques instants.', style: const TextStyle(color: AdpColors.muted)),
                  ],
                  const SizedBox(height: 28),
                  AdpPrimaryButton(label: 'Retour à l’ADP', onPressed: () => context.go('/home')),
                  const Spacer(),
                ]);
              },
            ),
          ),
        ),
      );
}
