import 'package:baobabe_0_2/features/settings/domain/entities/legal_document.dart';

/// La politique de confidentialité : ce que l'application collecte, pour
/// quoi, avec qui elle le partage, combien de temps, et ce que l'utilisateur
/// peut en faire.
///
/// Chaque ligne décrit ce que l'application **fait réellement** — pas ce
/// qu'une politique type promet. Si une collecte s'ajoute, cette page change
/// avec elle.
const LegalDocument privacyPolicy = LegalDocument(
  slug: 'confidentialite',
  title: 'Politique de confidentialité',
  updatedOn: '18 septembre 2026',
  intro:
      "Cette politique explique quelles données Baobabe collecte, pourquoi, "
      "et ce que vous pouvez en faire. Elle s'applique à l'application "
      "mobile et à sa version web. Découvrir les commerces et leurs offres "
      "ne demande aucun compte ; les données ci-dessous ne sont collectées "
      "qu'à partir du moment où vous en créez un.",
  sections: [
    LegalSection(
      title: 'Les données que nous collectons',
      paragraphs: [
        "Votre compte : adresse e-mail, nom et numéro de téléphone que vous "
            "renseignez, et le mot de passe (conservé sous forme chiffrée, "
            "jamais lisible).",
        "Vos adresses de livraison, si vous en enregistrez pour commander.",
        "Vos commandes, réservations et avis : ce que vous avez demandé, à "
            "quel commerce, à quelle date, pour quel montant, et la note que "
            "vous laissez ensuite.",
        "Vos notifications : les messages que la plateforme vous a adressés "
            "et le fait que vous les ayez lus. Si vous activez les "
            "notifications, l'identifiant technique de votre appareil qui "
            "permet de vous les envoyer.",
        "Pour un commerçant : les informations de son commerce (nom, adresse, "
            "horaires, photos, offres), et le nombre de fois où sa fiche et "
            "ses offres ont été ouvertes, compté par jour et sans identifier "
            "qui les a ouvertes.",
        "Nous ne collectons ni votre position, ni vos contacts, ni votre "
            "historique de navigation. L'application ne contient aucun outil "
            "publicitaire tiers.",
      ],
    ),
    LegalSection(
      title: 'Pourquoi nous les utilisons',
      paragraphs: [
        "Pour faire fonctionner le service : transmettre votre commande ou "
            "votre réservation au commerce, vous en montrer le suivi, vous "
            "prévenir quand elle change d'état.",
        "Pour vous joindre : le commerce peut avoir besoin de votre numéro "
            "pour une livraison ou un rendez-vous.",
        "Pour améliorer l'application : comprendre quelles fiches sont "
            "consultées, sans profilage individuel.",
        "Nous n'utilisons pas vos données pour de la publicité ciblée et ne "
            "les vendons à personne.",
      ],
    ),
    LegalSection(
      title: 'Avec qui nous les partageons',
      paragraphs: [
        "Le commerce concerné : quand vous commandez ou réservez, le "
            "commerçant voit votre nom, votre numéro de téléphone, l'adresse "
            "de livraison le cas échéant et le détail de votre demande. Il ne "
            "voit rien de vos autres commandes ni de vos autres adresses.",
        "Notre hébergeur, Supabase, qui stocke les données pour notre compte "
            "et ne les utilise pas pour lui-même.",
        "Les autorités, si la loi nous y oblige.",
        "Vos avis sont publics : ils apparaissent sur la fiche de l'offre "
            "avec le nom de votre profil.",
      ],
    ),
    LegalSection(
      title: 'Combien de temps nous les gardons',
      paragraphs: [
        "Tant que votre compte existe. Les commandes et réservations sont "
            "conservées comme historique — le vôtre, et celui du commerce "
            "pour ses propres obligations.",
        "À la suppression de votre compte, demandée par e-mail, vos données "
            "personnelles sont effacées ; les commandes passées peuvent être "
            "conservées sous une forme qui ne permet plus de vous identifier.",
      ],
    ),
    LegalSection(
      title: 'Vos droits',
      paragraphs: [
        "Vous pouvez consulter et corriger vos informations à tout moment "
            "depuis votre profil, dans les paramètres de l'application.",
        "Vous pouvez demander une copie de vos données, leur rectification ou "
            "la suppression de votre compte en écrivant à "
            "support@baobabe.cd. Nous répondons dans un délai de trente jours.",
        "Vous pouvez désactiver les notifications à tout moment depuis les "
            "paramètres, sans effet sur le reste du service.",
        "Ces droits s'exercent dans le cadre du Code du numérique de la "
            "République démocratique du Congo.",
      ],
    ),
    LegalSection(
      title: 'Sécurité',
      paragraphs: [
        "Les échanges entre l'application et nos serveurs sont chiffrés. "
            "L'accès aux données est restreint par des règles côté serveur : "
            "un utilisateur ne lit que les siennes, un commerçant ne voit que "
            "ce qui concerne son commerce.",
        "Aucun système n'est infaillible. En cas d'incident touchant vos "
            "données, nous vous en informerons.",
      ],
    ),
    LegalSection(
      title: 'Modifications',
      paragraphs: [
        "Cette politique peut évoluer avec l'application. La date en tête de "
            "page indique la dernière version ; un changement important vous "
            "sera signalé dans l'application.",
      ],
    ),
  ],
);
