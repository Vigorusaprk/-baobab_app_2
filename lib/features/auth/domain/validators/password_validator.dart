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

  static bool isValid(String password, {String? email}) {
    final trimmed = password.trim();
    if (trimmed.length < minLength) {
      return false;
    }
    final hasLetter = RegExp('[A-Za-z]').hasMatch(trimmed);
    final hasDigit = RegExp('[0-9]').hasMatch(trimmed);
    if (!hasLetter || !hasDigit) {
      return false;
    }
    final normalized = trimmed.toLowerCase();
    if (email != null && normalized == email.trim().toLowerCase()) {
      return false;
    }
    if (_obviousPasswords.contains(normalized)) {
      return false;
    }
    return true;
  }
}
