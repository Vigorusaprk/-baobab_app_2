import 'package:baobabe_0_2/features/settings/domain/entities/legal_document.dart';

/// Les conditions d'utilisation : ce que l'utilisateur et le commerçant
/// s'engagent à faire, et ce que la plateforme promet — rien de plus que ce
/// qu'elle tient.
const LegalDocument termsOfUse = LegalDocument(
  slug: 'conditions',
  title: "Conditions d'utilisation",
  updatedOn: '18 septembre 2026',
  intro:
      "En utilisant Baobabe, vous acceptez les conditions ci-dessous. Elles "
      "s'appliquent à toute personne qui consulte l'application, y crée un "
      "compte, y commande ou y réserve, et à tout commerçant qui y publie "
      "son commerce.",
  sections: [
    LegalSection(
      title: 'Le service',
      paragraphs: [
        "Baobabe présente des commerces de Kinshasa et ce qu'ils proposent, "
            "et permet de leur passer commande, de réserver chez eux ou de "
            "repérer ce qu'on ira chercher en boutique. Baobabe met en "
            "relation ; le commerce vend, prépare, livre ou accueille.",
        "Consulter l'application ne demande aucun compte. Commander, "
            "réserver, laisser un avis ou publier un commerce en demande un.",
      ],
    ),
    LegalSection(
      title: 'Votre compte',
      paragraphs: [
        "Vous devez avoir au moins dix-huit ans pour créer un compte. Les "
            "informations que vous renseignez doivent être exactes et tenues "
            "à jour : un commerçant qui ne peut pas vous joindre ne peut pas "
            "vous servir.",
        "Votre compte est personnel. Vous êtes responsable de ce qui est "
            "fait avec, et devez nous prévenir sans délai à "
            "support@baobabe.cd si vous pensez qu'il a été utilisé sans vous.",
      ],
    ),
    LegalSection(
      title: 'Commandes et réservations',
      paragraphs: [
        "Une commande ou une réservation passée dans l'application est une "
            "demande adressée au commerce. Elle devient ferme quand le "
            "commerce la confirme ; jusque-là, l'application la montre « en "
            "attente ». Le commerce peut la refuser, notamment s'il ne peut "
            "pas l'honorer.",
        "Les prix affichés sont ceux déclarés par le commerce, en dollars "
            "américains ou en francs congolais selon ce qu'il indique. Le "
            "paiement se fait auprès du commerce, selon ses moyens de "
            "paiement : Baobabe n'encaisse rien pour lui.",
        "Vous pouvez annuler une commande tant qu'elle n'a pas été livrée, "
            "et une réservation tant qu'elle n'a pas eu lieu, depuis "
            "l'application. Une annulation tardive peut laisser au commerce "
            "des frais déjà engagés : prévenez-le le plus tôt possible.",
        "Une réservation vaut pour la date, l'heure et le nombre de places "
            "indiqués. Prévenez le commerce si vous ne pouvez pas venir.",
      ],
    ),
    LegalSection(
      title: 'Les avis',
      paragraphs: [
        "Vous ne pouvez noter qu'une offre que vous avez effectivement "
            "reçue. Un avis doit porter sur votre expérience, rester "
            "respectueux et ne contenir ni donnée personnelle d'un tiers, ni "
            "propos injurieux, ni publicité.",
        "Nous pouvons retirer un avis qui ne respecte pas ces règles. Un "
            "commerçant ne peut ni modifier ni supprimer les avis reçus.",
      ],
    ),
    LegalSection(
      title: 'Les commerçants',
      paragraphs: [
        "Un commerçant s'engage à publier des informations exactes — nom, "
            "adresse, horaires, prix, disponibilité — et à les tenir à jour. "
            "Il est seul responsable de ses offres, de leur conformité à la "
            "loi et de leur bonne exécution.",
        "Un commerçant s'engage à traiter les demandes reçues dans un délai "
            "raisonnable, et à ne confirmer que ce qu'il peut honorer.",
        "Un commerce peut demander à être mis en avant dans l'application. "
            "Les conditions de cette mise en avant sont convenues avec "
            "l'éditeur ; elle ne modifie ni les notes ni les avis.",
        "Un compte ne gère qu'un seul commerce.",
      ],
    ),
    LegalSection(
      title: 'Ce qui est interdit',
      paragraphs: [
        "Utiliser l'application pour un usage contraire à la loi, publier un "
            "contenu trompeur ou portant atteinte à autrui, passer des "
            "commandes ou des réservations sans intention de les honorer, "
            "tenter d'accéder aux données d'un autre utilisateur ou de "
            "perturber le fonctionnement du service.",
        "En cas de manquement, nous pouvons suspendre ou fermer le compte "
            "concerné, sans préjudice des autres recours.",
      ],
    ),
    LegalSection(
      title: 'Responsabilité',
      paragraphs: [
        "Baobabe fournit l'application en l'état et fait ce qu'il faut pour "
            "qu'elle reste disponible, sans pouvoir garantir une absence "
            "totale d'interruption ou d'erreur.",
        "L'éditeur n'est pas partie aux transactions entre un utilisateur et "
            "un commerce. Il n'est pas responsable de la qualité d'une "
            "prestation, d'un retard, d'un produit non conforme ou d'un "
            "désaccord sur un paiement, qui se règlent avec le commerce. Il "
            "peut, à la demande de l'une des parties, aider à les mettre en "
            "contact.",
      ],
    ),
    LegalSection(
      title: 'Modifications et droit applicable',
      paragraphs: [
        "Ces conditions peuvent évoluer avec l'application. La date en tête "
            "de page indique la version en vigueur ; continuer à utiliser "
            "l'application après un changement vaut acceptation.",
        "Elles sont soumises au droit de la République démocratique du "
            "Congo. Tout litige relève des juridictions compétentes de "
            "Kinshasa, après une tentative de règlement amiable par écrit à "
            "support@baobabe.cd.",
      ],
    ),
  ],
);
