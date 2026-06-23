import 'package:flutter/material.dart';

class AppColors {
  // --- Couleurs de Marque & Structure ---
  // On utilise le beige comme couleur principale pour la structure de l'app
  static const Color primary = Color(0xFF956E2F);
  static const Color primaryDark = Color(0xFF654922);
  static const Color primaryLight = Color(0xFFB68B4B);

  // Le VERT devient la couleur secondaire (Accent / Action)
  // À utiliser UNIQUEMENT pour les boutons d'action, "Écrire un avis", "OUVERT", etc.
  static const Color secondary = Color(0xFF004741);
  static const Color secondaryDark = Color(0xFF04332D);
  static const Color secondaryLight = Color(0xFF306D64);

  // --- Fonds de l'application ---
  static const Color scaffoldBackground = Color(0xFFF0EDE4);
  static const Color canvasBackground = Color(0xFFF3EBDD);
  static const Color surface = Color(0xFFC6C6D0); // Pour les cartes (Cards) et conteneurs blancs cassés

  // --- Couleurs de Texte (Sobres et Contrastées) ---
  // Fini le texte vert pour les titres, on passe sur des vrais neutres sombres
  static const Color textPrimary = Color(0xFF1C1C1C);   // Titres principaux, noms des restos, "Contact & Accès"
  static const Color textSecondary = Color(0xFF555555); // Sous-titres, jours de la semaine (Lundi, Mardi)
  static const Color textMuted = Color(0xFF757575);     // Textes secondaires ou dates ("Il y a 1 semaine")

  // Textes sur boutons
  static const Color textOnPrimary = Color(0xFF1C1C1C); // Texte noir si le bouton est beige
  static const Color textOnSecondary = Colors.white;    // Texte blanc sur les boutons verts

  // --- Éléments de Saisie ---
  static const Color inputBackground = Color(0xFFEFEBE4);
  static const Color inputHint = Color(0xFF9E9E9E);

  // --- Couleurs Sémantiques & États ---
  static const Color success = Color(0xFF2E7D32); // Vert standard pour le succès
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // --- Couleurs Neutres Basiques ---
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color grey = Color(0xFF9E9E9E);

  // --- Couleurs par Type de Business ---
  // (Le restaurant garde son rouge pour la carte de l'accueil, comme sur votre maquette)
  static const Color Restaurant = Color(0xFFE53935);
  static const Color FastFood = Color(0xFFFB8C00);
  static const Color Shopping = Color(0xFF1E88E5);
  static const Color Mall = Color(0xFF8E24AA);
  static const Color Hotel = Color(0xFF3949AB);
  static const Color CarRental = Color(0xFF2E7D32);
  static const Color TravelAgency = Color(0xFF00ACC1);
  static const Color Spa = Color(0xFF66BB6A);
  static const Color Cinema = Color(0xFFC62828);
  static const Color Tourisme = Color(0xFF704545);

  // --- Couleurs des Avatars Utilisateurs ---
  static const List<Color> avatarColors = [
    Color(0xFFFF7D53),
    Color(0xFF9260F4),
    Color(0xFF0087FF),
    Color(0xFFFFB300),
    Color(0xFF26A69A),
    Color(0xFFEC407A),
  ];
}

