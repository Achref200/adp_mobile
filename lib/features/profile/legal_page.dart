import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// In-app legal pages required by Google Play and the App Store:
/// Terms of Service (EULA), Privacy Policy, and data-deletion instructions.
class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.document});

  /// 'terms' | 'privacy' | 'data-deletion'
  final String document;

  @override
  Widget build(BuildContext context) {
    final (_, title, updated, sections) = switch (document) {
      'privacy' => (
        'privacy',
        'Politique de Confidentialité',
        DateTime(2026, 9, 1),
        _privacySections,
      ),
      'data-deletion' => (
        'data-deletion',
        'Suppression des Données',
        DateTime(2026, 9, 1),
        _deletionSections,
      ),
      _ => (
        'terms',
        'Conditions Générales d\u2019Utilisation',
        DateTime(2026, 9, 1),
        _termsSections,
      ),
    };

    return Scaffold(
      backgroundColor: AdpColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AdpStudioBackButton(),
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            'Association Djerba Project — Dernière mise à jour : ${DateFormat('dd/MM/yyyy').format(updated)}',
            style: const TextStyle(fontSize: 12, color: AdpColors.muted),
          ),
          const SizedBox(height: 18),
          ...[
            for (final (index, section) in sections.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${section.$1}',
                      style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AdpColors.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      section.$2,
                      style: const TextStyle(
                          fontSize: 13.5,
                          color: AdpColors.inkSoft,
                          height: 1.55),
                    ),
                  ],
                ),
              ),
          ],
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Association Djerba Project · Djerba, Tunisie\ncontact@djerbaproject.fr',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AdpColors.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}

typedef _Section = (String, String);

const List<_Section> _termsSections = [
  (
    'Objet',
    "Les présentes conditions régissent l'utilisation de l'application mobile "
        "« ADP — Association Djerba Project » éditée par l'Association Djerba "
        "Project, association à but non lucratif de droit tunisien dont le siège "
        "est situé à Djerba. En créant un compte ou en utilisant l'application, "
        "vous acceptez ces conditions sans réserve.",
  ),
  (
    'Compte membre',
    "L'inscription est réservée aux personnes physiques majeures. Vous vous "
        "engagez à fournir des informations exactes (identité, pays de "
        "résidence) et à conserver vos identifiants confidentiels. Chaque membre "
        "est responsable de l'activité réalisée depuis son compte. Vous pouvez "
        "supprimer votre compte à tout moment depuis l'écran « Mon Profil ».",
  ),
  (
    'Adhésion et cotisations',
    "L'adhésion à l'association est soumise à validation du bureau et au "
        "paiement d'une cotisation annuelle. Le statut « membre actif » ouvre "
        "l'accès au e-Pass numérique et à l'annuaire des membres. La cotisation "
        "n'est pas remboursable, sauf décision contraire du bureau.",
  ),
  (
    'Dons',
    "Les dons ponctuels ou mensuels sont collectés via notre prestataire de "
        "paiement HelloAsso. Un reçu fiscal est délivré pour les dons ouvrant "
        "droit à réduction. Le don est affecté aux projets citoyens présentés "
        "dans l'application ; en cas d'impossibilité d'exécution, l'association "
        "peut réaffecter le don à un projet d'intérêt équivalent.",
  ),
  (
    "e-Pass et évènements",
    "Le e-Pass est un titre d'accès numérique nominatif, personnel et "
        "non transférable, dont la validité suit celle de votre adhésion. Toute "
        "fraude ou tentative de reproduction expose à la suspension du compte "
        "et au refus d'accès aux évènements de l'association (dont le Sommet "
        "Diaspora).",
  ),
  (
    'Annuaire et bonnes pratiques',
    "L'annuaire des membres permet les mises en relation professionnelles au "
        "sein de la communauté. Vous contrôlez votre visibilité à tout moment. "
        "Sont interdits : démarchage commercial abusif, propos discriminatoires, "
        "contenus illicites. L'association peut suspendre tout compte "
        "contrevenant après notification.",
  ),
  (
    'Propriété intellectuelle',
    "Les contenus (textes, projets, identité visuelle, logo) sont la propriété "
        "de l'Association Djerba Project ou de leurs auteurs respectifs. Toute "
        "reproduction sans autorisation écrite est interdite.",
  ),
  (
    'Responsabilité',
    "L'association s'efforce d'assurer la disponibilité de l'application mais "
        "ne saurait être tenue responsable des interruptions temporaires, ni des "
        "contenus publiés par les membres sur l'annuaire.",
  ),
  (
    'Évolution des conditions',
    "Les présentes conditions peuvent être modifiées. Les membres seront "
        "informés par notification dans l'application au moins 15 jours avant "
        "l'entrée en vigueur des nouvelles versions. La version applicable est "
        "celle consultable dans l'application.",
  ),
  (
    'Droit applicable',
    "Les présentes conditions sont soumises au droit tunisien. En cas de "
        "litige, et à défaut de résolution amiable, les tribunaux compétents "
        "de Tunis seront saisies.",
  ),
];

const List<_Section> _privacySections = [
  (
    'Données collectées',
    "Dans le cadre de la gestion des membres et des dons, nous collectons : "
        "identité (prénom, nom), adresse e-mail, pays de résidence, et si vous "
        "activez l'annuaire : ville, secteur d'activité et compétences. Les "
        "paiements sont traités par HelloAsso ; nous ne stockons aucune donnée "
        "bancaire. Les journaux techniques (connexion, appareil) peuvent être "
        "conservés à des fins de sécurité.",
  ),
  (
    'Finalités',
    "Vos données servent exclusivement à : gérer votre adhésion et vos dons, "
        "éditer vos reçus fiscaux, vous permettre d'accéder aux évènements "
        "(e-Pass), animer l'annuaire des membres si vous l'activez, et vous "
        "adresser les notifications que vous avez choisies. Aucune donnée n'est "
        "vendue ni cédée à des tiers commerciaux.",
  ),
  (
    'Base légale et consentements',
    "Les traitements reposent sur l'exécution du contrat d'adhésion, notre "
        "intérêt légitime de sécurité et votre consentement pour l'annuaire, "
        "les communications et les statistiques d'usage. Chaque consentement "
        "est enregistré horodaté et peut être retiré à tout moment depuis "
        "l'application.",
  ),
  (
    'Durée de conservation',
    "Les données de compte sont conservées pendant la durée de votre adhésion "
        "puis archivées 3 ans après votre dernier contact. Les pièces "
        "comptables (dons, cotisations) sont conservées 10 ans conformément aux "
        "obligations légales tunisiennes.",
  ),
  (
    'Vos droits (RGPD)',
    "Conformément au RGPD et à la loi tunisienne 63-5 sur la protection des "
        "données personnelles, vous disposez d'un droit d'accès, de "
        "rectification, d'effacement, de portabilité et d'opposition. "
        "L'export de vos données est disponible dans l'application (Mon Profil "
        "→ Exporter mes données). La demande d'effacement est traitée sous 30 "
        "jours.",
  ),
  (
    'Sécurité',
    "Les mots de passe sont chiffrés (bcrypt), les sessions reposent sur des "
        "jetons courts rotatifs stockés dans l'enclave sécurisée de votre "
        "appareil (Keychain / Keystore). Les échanges sont chiffrés (HTTPS). "
        "L'accès à la base par le bureau de l'association est limité aux "
        "fonctions nécessaires.",
  ),
  (
    'Sous-traitants',
    "Nous utilisons un nombre limité de prestataires : HelloAsso (paiement), "
        "Google (authentification « Continuer avec Google », si vous "
        "l'utilisez), et notre hébergeur applicatif dans l'Union européenne.",
  ),
  (
    'Contact',
    "Pour exercer vos droits : contact@djerbaproject.fr ou par courrier à "
        "l'Association Djerba Project, Djerba, Tunisie. Vous pouvez également "
        "saisir l'autorité de contrôle compétente (INPDP en Tunisie ou CNIL en "
        "France).",
  ),
];

const List<_Section> _deletionSections = [
  (
    'Supprimer mon compte',
    "Depuis l'application : onglet « Profil » → « Supprimer mon compte ». "
        "Votre demande est enregistrée et traitée par le bureau sous 30 jours "
        "au maximum. Vous recevez une confirmation par e-mail.",
  ),
  (
    'Ce qui est supprimé',
    "Profil (identité, e-mail, pays), profil annuaire (ville, secteur, "
        "compétences), préférences de notifications, demandes de mise en "
        "relation, jetons d'appareil et historique de notifications.",
  ),
  (
    'Ce qui est conservé',
    "Les éléments comptables liés aux dons et cotisations (obligation légale "
        "de conservation de 10 ans) sont anonymisés : ils ne sont plus rattachés "
        "à votre identité.",
  ),
  (
    'Suppression par e-mail',
    "Vous pouvez aussi adresser votre demande depuis l'adresse associée à "
        "votre compte : contact@djerbaproject.fr (délai de traitement : 30 "
        "jours).",
  ),
];
