import 'package:baobabe_0_2/features/settings/domain/entities/legal_document.dart';
import 'package:baobabe_0_2/features/settings/domain/legal/legal_notice.dart';
import 'package:baobabe_0_2/features/settings/domain/legal/privacy_policy.dart';
import 'package:baobabe_0_2/features/settings/domain/legal/terms_of_use.dart';

export 'package:baobabe_0_2/features/settings/domain/entities/legal_document.dart';

/// Les textes juridiques de l'application, dans l'ordre où les paramètres
/// les listent.
const List<LegalDocument> legalDocuments = [
  legalNotice,
  privacyPolicy,
  termsOfUse,
];

/// Le document derrière un `slug` de route, ou `null` s'il n'existe pas.
LegalDocument? legalDocumentBySlug(String slug) {
  for (final document in legalDocuments) {
    if (document.slug == slug) return document;
  }
  return null;
}
