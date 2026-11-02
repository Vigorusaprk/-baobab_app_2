/// Politique de mot de passe de Baobabe.
///
/// Un mot de passe doit faire au moins [minLength] caractères, contenir
/// une lettre et un chiffre, différer de l'e-mail saisi, et éviter une
/// liste courte de mots évidents.
class PasswordValidator {
  static const int minLength = 10;

  static final List<String> _obviousPasswords = <String>[
    'password',
    '123456',
    '12345678',
    'qwerty',
    'azerty',
    'letmein',
    'welcome',
    'admin',
    'monkey',
    'football',
  ];

  /// Vérifie la longueur minimale après trim.
  static bool hasMinLength(String password) =>
      password.trim().length >= minLength;

  /// Vérifie la présence d'au moins une lettre et d'un chiffre.
  static bool hasLetterAndDigit(String password) {
    final value = password.trim();
    return RegExp('[A-Za-z]').hasMatch(value) && RegExp('[0-9]').hasMatch(value);
  }

  /// Vérifie la différence avec l'e-mail (une contrainte absente vaut
  /// comme une absence de contrainte).
  static bool isDifferentFromEmail(String password, String? email) {
    if (email == null) return true;
    return password.trim().toLowerCase() != email.trim().toLowerCase();
  }

  /// Vérifie l'absence de mot de passe évident (insensible à la casse).
  static bool isNotObvious(String password) =>
      !_obviousPasswords.contains(password.trim().toLowerCase());

  /// Verdict complet : toutes les règles doivent être satisfaites.
  static bool isValid(String password, {String? email}) {
    final trimmed = password.trim();
    if (!hasMinLength(trimmed)) return false;
    if (!hasLetterAndDigit(trimmed)) return false;
    if (!isDifferentFromEmail(trimmed, email)) return false;
    if (!isNotObvious(trimmed)) return false;
    return true;
  }
}
