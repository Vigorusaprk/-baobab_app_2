import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/settings/domain/legal/legal_documents.dart';
import 'package:baobabe_0_2/features/settings/presentation/screens/legal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Les textes juridiques se lisent dans l'application.
///
/// Les paramètres ont eu une section « Application » dont les deux entrées
/// n'ouvraient rien, puis plus de section du tout. Ces tests tiennent que
/// chaque entrée a un texte derrière elle, et que ce texte s'affiche.
void main() {
  test('trois documents, trois adresses distinctes', () {
    expect(legalDocuments, hasLength(3));
    expect(
      legalDocuments.map((d) => d.slug).toSet(),
      hasLength(legalDocuments.length),
    );
    for (final document in legalDocuments) {
      expect(document.sections, isNotEmpty, reason: document.title);
      for (final section in document.sections) {
        expect(section.paragraphs, isNotEmpty, reason: section.title);
      }
      expect(legalDocumentBySlug(document.slug), same(document));
    }
    expect(legalDocumentBySlug('inconnu'), isNull);
  });

  testWidgets('chaque document s\'affiche en entier, sans déborder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    for (final document in legalDocuments) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.silvaTheme,
          // Une clé par document : sans elle, la liste garde la position de
          // défilement du document précédent et l'en-tête du suivant n'est
          // pas construit.
          home: LegalPage(key: ValueKey(document.slug), document: document),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(document.title), findsOneWidget);
      expect(find.textContaining(document.updatedOn), findsOneWidget);

      // Le dernier paragraphe est bien là, au bout du défilement.
      final last = document.sections.last.paragraphs.last;
      await tester.scrollUntilVisible(find.text(last), 400);
      expect(find.text(last), findsOneWidget);
    }
  });

  testWidgets('une adresse inconnue donne un message, pas une exception', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.silvaTheme,
        home: const LegalRoutePage(slug: 'nimporte-quoi'),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("Ce document n'existe pas."), findsOneWidget);
  });
}
