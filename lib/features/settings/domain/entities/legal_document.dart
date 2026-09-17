/// Un texte juridique de l'application — mentions légales, politique de
/// confidentialité, conditions d'utilisation.
///
/// Le contenu vit **dans l'application**, pas derrière une adresse web :
/// un utilisateur hors ligne, ou sans navigateur sous la main, doit pouvoir
/// lire ce à quoi il s'engage. Trois documents, une seule forme : un titre,
/// une date, des sections.
class LegalDocument {
  const LegalDocument({
    required this.slug,
    required this.title,
    required this.updatedOn,
    required this.intro,
    required this.sections,
  });

  /// Identifiant dans la route (`/legal/:slug`).
  final String slug;
  final String title;

  /// La date affichée en tête : « Dernière mise à jour ».
  final String updatedOn;

  /// Le paragraphe d'ouverture, avant la première section.
  final String intro;
  final List<LegalSection> sections;
}

class LegalSection {
  const LegalSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;
}
