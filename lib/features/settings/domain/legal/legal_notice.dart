import 'package:baobabe_0_2/features/settings/domain/entities/legal_document.dart';

/// Les mentions légales : qui édite l'application, qui l'héberge, à qui
/// écrire.
///
/// Les champs entre crochets — raison sociale, immatriculation, adresse —
/// attendent les informations de l'entreprise : ils ne s'inventent pas.
const LegalDocument legalNotice = LegalDocument(
  slug: 'mentions-legales',
  title: 'Mentions légales',
  updatedOn: '18 septembre 2026',
  intro:
      "Baobabe est une application mobile et web qui met en relation les "
      "habitants de Kinshasa avec les commerces de la ville : restaurants, "
      "hôtels, boutiques, services, loisirs. Les informations ci-dessous "
      "identifient l'éditeur de l'application et les conditions de son "
      "hébergement.",
  sections: [
    LegalSection(
      title: "Éditeur de l'application",
      paragraphs: [
        "L'application Baobabe est éditée par [raison sociale de "
            "l'éditeur], [forme juridique], immatriculée au registre du "
            "commerce et du crédit mobilier sous le numéro [RCCM], dont le "
            "siège est situé à [adresse], Kinshasa, République démocratique "
            "du Congo.",
        "Directeur de la publication : [nom et qualité].",
        "Contact : support@baobabe.cd.",
      ],
    ),
    LegalSection(
      title: 'Hébergement',
      paragraphs: [
        "Les données de l'application (comptes, commerces, offres, commandes, "
            "réservations, avis) sont hébergées par Supabase, Inc. "
            "(supabase.com), sur une infrastructure en nuage sécurisée.",
        "Les images publiées par les commerçants sont stockées sur cette même "
            "infrastructure.",
      ],
    ),
    LegalSection(
      title: 'Propriété intellectuelle',
      paragraphs: [
        "Le nom Baobabe, le logo, l'interface et les textes de l'application "
            "sont la propriété de l'éditeur. Toute reproduction ou "
            "réutilisation, en tout ou partie, sans autorisation écrite "
            "préalable est interdite.",
        "Les photos, descriptions et prix des commerces et de leurs offres "
            "sont publiés par les commerçants eux-mêmes, qui en restent "
            "propriétaires et responsables.",
      ],
    ),
    LegalSection(
      title: "Nature du service",
      paragraphs: [
        "Baobabe est une plateforme de mise en relation. L'éditeur ne vend "
            "aucun produit, ne fournit aucune prestation et n'encaisse aucun "
            "paiement pour le compte des commerçants. Une commande ou une "
            "réservation passée dans l'application engage l'utilisateur "
            "envers le commerce concerné, qui en assure seul l'exécution.",
        "Les informations affichées — horaires, disponibilité, prix — sont "
            "celles déclarées par chaque commerce. L'éditeur les publie en "
            "l'état et ne peut en garantir l'exactitude à chaque instant.",
      ],
    ),
    LegalSection(
      title: 'Signaler un contenu',
      paragraphs: [
        "Un contenu inexact, trompeur ou contraire à la loi peut être signalé "
            "à support@baobabe.cd, en indiquant le commerce ou l'offre "
            "concernée. L'éditeur examine chaque signalement et retire le "
            "contenu s'il y a lieu.",
      ],
    ),
    LegalSection(
      title: 'Droit applicable',
      paragraphs: [
        "L'application et les présentes mentions sont soumises au droit de la "
            "République démocratique du Congo. Tout litige relatif à leur "
            "interprétation ou à leur exécution relève des juridictions "
            "compétentes de Kinshasa.",
      ],
    ),
  ],
);
