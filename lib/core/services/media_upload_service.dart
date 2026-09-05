import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Les photos d'un commerce, envoyées depuis l'appareil.
///
/// Jusqu'ici il fallait coller une URL : un commerçant sans site n'avait donc
/// aucun moyen de publier une image, et plusieurs liens en base pointent vers
/// des pages web au lieu de fichiers.
///
/// **Le chemin décide du droit d'écrire.** Une policy sur `storage.objects`
/// n'autorise l'écriture que si le premier segment est un commerce dont
/// l'appelant est le personnel actif — d'où la convention
/// `<business_id>/<sorte>/<horodatage>.<ext>`. Aucune fonction edge au
/// milieu : un flux binaire n'a rien à gagner à traverser Deno.
///
/// Les octets, et jamais un chemin de fichier : sur le web il n'existe pas de
/// système de fichiers, et `XFile.path` y est une URL de blob que le SDK ne
/// sait pas lire.
class MediaUploadService {
  MediaUploadService({SupabaseClient? supabase, ImagePicker? picker})
    : _supabase = supabase ?? SupabaseClientWrapper.client,
      _picker = picker ?? ImagePicker();

  final SupabaseClient _supabase;
  final ImagePicker _picker;

  static const String bucket = 'merchant-media';

  /// Le plus grand côté conservé. Une photo de téléphone fait 4 000 px de
  /// large : la réduire avant l'envoi, c'est autant de réseau économisé sur
  /// une connexion irrégulière.
  static const double _maxSide = 1600;

  /// Assez pour une vitrine, pas assez pour peser deux mégaoctets.
  static const int _quality = 82;

  /// Choisit une image, la réduit, et l'envoie. Rend l'URL publique.
  ///
  /// `null` quand l'utilisateur referme le sélecteur sans rien choisir — ce
  /// qui n'est pas une erreur et ne doit rien afficher.
  Future<String?> pickAndUpload({
    required String businessId,
    required MediaKind kind,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    return upload(
      businessId: businessId,
      kind: kind,
      bytes: bytes,
      fileName: picked.name,
      mimeType: picked.mimeType,
    );
  }

  /// Envoie des octets déjà en main. Séparé de la sélection pour que le
  /// service se teste sans sélecteur de photos.
  Future<String> upload({
    required String businessId,
    required MediaKind kind,
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    final extension = _extensionOf(fileName, mimeType);
    final path =
        '$businessId/${kind.folder}/'
        '${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentTypeOf(extension),
            // Un remplacement écrase, il n'empile pas : le nom porte
            // l'horodatage, donc une collision ne peut venir que d'un double
            // envoi de la même image.
            upsert: true,
          ),
        );

    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// Retire une photo du stockage.
  ///
  /// Ne lève pas : une image déjà absente, ou hébergée ailleurs — les
  /// anciennes URL collées à la main — n'est pas un incident.
  Future<void> remove(String publicUrl) async {
    final path = pathOf(publicUrl);
    if (path == null) return;
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      debugPrint('Photo non supprimée ($path) : $e');
    }
  }

  /// Le chemin interne d'une URL publique de ce bucket, ou `null` si l'URL
  /// vient d'ailleurs.
  static String? pathOf(String publicUrl) {
    const marker = '/storage/v1/object/public/$bucket/';
    final index = publicUrl.indexOf(marker);
    if (index < 0) return null;
    return Uri.decodeComponent(publicUrl.substring(index + marker.length));
  }

  static String _extensionOf(String fileName, String? mimeType) {
    final dot = fileName.lastIndexOf('.');
    if (dot > 0 && dot < fileName.length - 1) {
      final raw = fileName.substring(dot + 1).toLowerCase();
      if (raw == 'jpg' || raw == 'jpeg' || raw == 'png' || raw == 'webp') {
        return raw == 'jpeg' ? 'jpg' : raw;
      }
    }
    // Le sélecteur web ne donne pas toujours d'extension : le type MIME
    // reste la seule indication.
    if (mimeType == 'image/png') return 'png';
    if (mimeType == 'image/webp') return 'webp';
    return 'jpg';
  }

  static String _contentTypeOf(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}

/// À quoi sert la photo. Décide du dossier, donc de ce qu'on peut nettoyer
/// plus tard sans se demander ce qu'on efface.
enum MediaKind {
  cover,
  offer;

  String get folder => switch (this) {
    MediaKind.cover => 'cover',
    MediaKind.offer => 'offers',
  };
}
