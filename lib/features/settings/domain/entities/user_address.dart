import 'package:equatable/equatable.dart';

/// L'adresse d'un utilisateur, du plus large au plus précis.
///
/// Le découpage vient de la façon dont une adresse se dit à Kinshasa :
/// province, ville, commune, quartier, avenue, numéro. Chaque palier est une
/// colonne de `user_info` plutôt qu'une ligne de texte libre — c'est ce qui
/// permettra plus tard de grouper les livraisons par commune sans avoir à
/// deviner ce que contient une chaîne.
///
/// [numero] est du **texte** : « 10F » est un numéro de parcelle courant, et
/// un entier l'aurait refusé.
class UserAddress extends Equatable {
  const UserAddress({
    this.province = defaultProvince,
    this.ville,
    this.commune,
    this.quartier,
    this.avenue,
    this.numero,
  });

  /// La plupart des utilisateurs sont à Kinshasa : c'est la valeur proposée
  /// d'emblée, pour que le formulaire démarre déjà à moitié rempli.
  static const String defaultProvince = 'Kinshasa';

  final String province;
  final String? ville;
  final String? commune;
  final String? quartier;
  final String? avenue;
  final String? numero;

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final value = json[key]?.toString().trim();
      return (value == null || value.isEmpty) ? null : value;
    }

    return UserAddress(
      province: read('province') ?? defaultProvince,
      ville: read('ville'),
      commune: read('commune'),
      quartier: read('quartier'),
      avenue: read('avenue'),
      numero: read('numero'),
    );
  }

  Map<String, dynamic> toJson() => {
    'province': province,
    'ville': ville,
    'commune': commune,
    'quartier': quartier,
    'avenue': avenue,
    'numero': numero,
  };

  /// Une adresse dont il ne reste que la province par défaut n'a pas été
  /// renseignée : on ne peut livrer nulle part avec ça.
  bool get isEmpty =>
      (ville ?? commune ?? quartier ?? avenue ?? numero) == null;

  bool get isNotEmpty => !isEmpty;

  /// L'adresse sur **une seule ligne**, du précis au large — comme on la dit
  /// à voix haute : « N° 10F, Av. Kasa-Vubu, Q. Lingwala, C. Gombe, Kinshasa ».
  ///
  /// Les paliers absents sont omis. Une adresse à moitié remplie ne doit pas
  /// produire de virgules orphelines : c'est le cas courant tant que
  /// l'utilisateur n'a pas terminé sa fiche.
  String get oneLine {
    final parts = <String>[
      if (numero != null) 'N° $numero',
      if (avenue != null) 'Av. $avenue',
      if (quartier != null) 'Q. $quartier',
      if (commune != null) 'C. $commune',
      if (ville != null && ville != province) ville!,
      province,
    ];
    return parts.join(', ');
  }

  UserAddress copyWith({
    String? province,
    String? ville,
    String? commune,
    String? quartier,
    String? avenue,
    String? numero,
  }) => UserAddress(
    province: province ?? this.province,
    ville: ville ?? this.ville,
    commune: commune ?? this.commune,
    quartier: quartier ?? this.quartier,
    avenue: avenue ?? this.avenue,
    numero: numero ?? this.numero,
  );

  @override
  List<Object?> get props => [
    province,
    ville,
    commune,
    quartier,
    avenue,
    numero,
  ];
}

/// Une province et ses villes, telles que le serveur les donne.
///
/// La liste vit en base, pas dans l'application : ajouter une ville ne demande
/// pas de publier une nouvelle version. Même principe que les catégories.
class Province extends Equatable {
  const Province({required this.name, required this.cities});

  final String name;
  final List<String> cities;

  factory Province.fromJson(Map<String, dynamic> json) => Province(
    name: json['name']?.toString() ?? '',
    cities: ((json['cities'] as List?) ?? const [])
        .map((c) => c.toString())
        .toList(),
  );

  @override
  List<Object?> get props => [name, cities];
}

/// L'identité de l'utilisateur, telle qu'elle vit dans `users`.
class UserProfile extends Equatable {
  const UserProfile({this.name, this.email, this.phone});

  final String? name;
  final String? email;
  final String? phone;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final value = json[key]?.toString().trim();
      return (value == null || value.isEmpty) ? null : value;
    }

    return UserProfile(
      name: read('name'),
      email: read('email'),
      phone: read('phone'),
    );
  }

  /// Ce que l'utilisateur peut renseigner lui-même. L'e-mail vient du compte
  /// et ne se modifie pas ici, il ne compte donc pas.
  bool get isIncomplete => name == null || phone == null;

  @override
  List<Object?> get props => [name, email, phone];
}
