/// SMTP / Google OAuth2 email sending contract for ADP.
///
/// Usage:
/// 1. Set the following environment variables (or dart-defines at build time):
///
///    # Google Workspace / Gmail SMTP (XOAuth2)
///    SMTP_HOST=smtp.gmail.com
///    SMTP_PORT=587              # STARTTLS
///    SMTP_USERNAME=adp@djerbaproject.fr
///    # OAuth2 refresh token for the above account (generated via Google OAuth2 flow)
///    SMTP_XOAUTH2_REFRESH_TOKEN=...
///    SMTP_XOAUTH2_CLIENT_ID=...
///    SMTP_XOAUTH2_CLIENT_SECRET=...
///
///    # ADP sender settings
///    MAIL_FROM=no-reply@djerbaproject.fr
///    MAIL_FROM_NAME="Association Djerba Project"
///
/// 2. For Gmail / Google Workspace, you must:
///    - Enable 2-step verification on the Google account
///    - Generate an App Password (if using basic auth) OR
///    - Register an OAuth2 client in Google Cloud Console
///      (api-admin.google.com) with scope https://mail.google.com
///    - Generate a refresh token and store it in SMTP_XOAUTH2_REFRESH_TOKEN
///
/// 3. The backend (Node/Express or similar) should handle the actual SMTP
///    sending. This contract defines the payloads the backend expects.
///
/// Supported email types:
///  - referral_thank_you      : when a new member signs up with a referral code
///  - membership_confirmation : after membership submission
///  - content_published       : when a content creator's draft is published
///  - welcome_email           : first-time member welcome

class AdpMailPayload {
  final String to;
  final String subject;
  final String bodyHtml;
  final String? bodyText;

  const AdpMailPayload({
    required this.to,
    required this.subject,
    required this.bodyHtml,
    this.bodyText,
  });
}

/// Reference payloads that the backend can use to send emails via SMTP.
class AdpMailTemplates {
  static AdpMailPayload referralThankYou({
    required String memberName,
    required String referrerName,
    required String referrerEmail,
  }) {
    return AdpMailPayload(
      to: referrerEmail,
      subject: 'ADP · Parrainage — ${memberName} vient de rejoindre l\'association',
      bodyHtml: '''
<div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#0E2129;">
  <div style="background:#008891;padding:24px 20px;border-radius:12px 12px 0 0;">
    <h1 style="margin:0;font-size:20px;font-weight:800;color:#fff;">Association Djerba Project</h1>
  </div>
  <div style="padding:24px 20px;background:#FBF9F5;border-radius:0 0 12px 12px;">
    <p style="font-size:14px;line-height:1.6;color:#2D424B;">
      <strong>${memberName}</strong> vient de finaliser son adhésion à ADP
      grâce à votre recommandation. Merci pour votre rôle de parrain !
    </p>
    <p style="font-size:14px;line-height:1.6;color:#2D424B;margin-top:16px;">
      Le réseau ADP grandit grâce à des membres comme vous.
      Nous vous tiendrons informé des activités et projets.
    </p>
    <hr style="border:none;border-top:1px solid #E7E2D8;margin:20px 0;">
    <p style="font-size:12px;color:#687B82;">
      Ceci est un email automatique de l'Association Djerba Project.
      Ne répondez pas à cet email.
    </p>
  </div>
</div>
      ''',
    );
  }

  static AdpMailPayload membershipConfirmation({
    required String memberName,
    required String plan,
    required int amountCents,
  }) {
    return AdpMailPayload(
      to: '', // Filled by backend with member email
      subject: 'ADP · Votre adhésion — Formule $plan',
      bodyHtml: '''
<div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#0E2129;">
  <div style="background:#008891;padding:24px 20px;border-radius:12px 12px 0 0;">
    <h1 style="margin:0;font-size:20px;font-weight:800;color:#fff;">Adhésion confirmée</h1>
  </div>
  <div style="padding:24px 20px;background:#FBF9F5;border-radius:0 0 12px 12px;">
    <p style="font-size:14px;line-height:1.6;color:#2D424B;">
      Bonjour <strong>${memberName}</strong>,
    </p>
    <p style="font-size:14px;line-height:1.6;color:#2D424B;margin-top:12px;">
      Votre adhésion en tant que <strong>Membre ${plan}</strong> (cotisation annuelle de ${(amountCents / 100).toStringAsFixed(0)} €)
      a été enregistrée. Le bureau ADP procédera à la validation dans les jours à venir.
    </p>
    <p style="font-size:14px;line-height:1.6;color:#2D424B;margin-top:12px;">
      Une fois validé, vous recevrez votre e-Pass membre par email.
    </p>
    <hr style="border:none;border-top:1px solid #E7E2D8;margin:20px 0;">
    <p style="font-size:12px;color:#687B82;">
      Association Djerba Project — Houmt Souk, Djerba, Tunisie
    </p>
  </div>
</div>
      ''',
    );
  }

  static AdpMailPayload contentPublished({
    required String creatorName,
    required String contentType,
    required String contentTitle,
  }) {
    return AdpMailPayload(
      to: '', // Filled by backend with creator email
      subject: 'ADP · Votre contenu est maintenant publié',
      bodyHtml: '''
<div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#0E2129;">
  <div style="background:#1F8A65;padding:24px 20px;border-radius:12px 12px 0 0;">
    <h1 style="margin:0;font-size:20px;font-weight:800;color:#fff;">Contenu publié</h1>
  </div>
  <div style="padding:24px 20px;background:#FBF9F5;border-radius:0 0 12px 12px;">
    <p style="font-size:14px;line-height:1.6;color:#2D424B;">
      Félicitations <strong>${creatorName}</strong>,
    </p>
    <p style="font-size:14px;line-height:1.6;color:#2D424B;margin-top:12px;">
      Votre <strong>${contentType}</strong> « ${contentTitle} » a été validé et est maintenant visible
      par l'ensemble des membres de l'application ADP.
    </p>
    <hr style="border:none;border-top:1px solid #E7E2D8;margin:20px 0;">
    <p style="font-size:12px;color:#687B82;">
      Association Djerba Project
    </p>
  </div>
</div>
      ''',
    );
  }
}
