import 'dart:ui';
import 'package:flutter/material.dart';

class AcrylicCardExample extends StatelessWidget {
  const AcrylicCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // Dimensions de la carte
        width: 380,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          // Une ombre légère pour détacher la carte du fond de l'application
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // ClipRRect est INDISPENSABLE pour que le flou ne bave pas hors des arrondis
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // ---------------------------------------------------------------
              // COUCHE 1 : Les orbes de lumière (Arrière-plan)
              // ---------------------------------------------------------------
              _buildBackgroundOrbes(),

              // ---------------------------------------------------------------
              // COUCHE 2 : L'effet Acrylique (Flou + Teinte translucide)
              // ---------------------------------------------------------------
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65), // Teinte blanche très douce
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4), // Bordure style "verre poli"
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // COUCHE 3 : Le Contenu (Texte, Boutons, Hiérarchie)
              // ---------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ligne du haut : Catégorie et Niveau
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Étude biblique',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          'Niveau 1',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),

                    // Ligne du bas : Titre principal et Bouton Chapitre
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Titre principal (Flexible pour éviter les dépassements)
                        Expanded(
                          child: Text(
                            'Généralités sur la\nBible',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1C),
                              height: 1.2,
                            ),
                          ),
                        ),

                        // Bouton Chapitre 1
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD2E3F7), // Bleu opaque de la maquette
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Chapitre 1',
                            style: TextStyle(
                              color: Color(0xFF1A535C), // Couleur du texte du bouton
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget d'aide pour générer les points lumineux flous en arrière-plan
  Widget _buildBackgroundOrbes() {
    return Stack(
      children: [
        // Orbe Bleu (En haut à droite)
        Positioned(
          top: -20,
          right: 40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A90E2).withOpacity(0.25),
            ),
          ),
        ),
        // Orbe Jaune/Ambre (En bas à droite, sous le bouton)
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD166).withOpacity(0.4),
            ),
          ),
        ),
        // Orbe Rose/Pêche discret (À gauche)
        Positioned(
          bottom: 30,
          left: -10,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFADAD).withOpacity(0.15),
            ),
          ),
        ),
      ],
    );
  }
}