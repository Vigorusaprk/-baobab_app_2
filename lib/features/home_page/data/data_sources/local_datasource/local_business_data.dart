import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

abstract class BusinessLocalDataSource {
  Future<List<BusinessModel>> getBusinesses();
  Future<BusinessModel> getBusinessDetail(String businessId);
  Future<List<BusinessModel>> getBusinessesByCategory(String category);
  Future<void> cacheBusiness(BusinessModel business);
  Future<void> cacheBusinesses(List<BusinessModel> businesses);
  Future<void> toggleFavorite(String businessId);
  Future<bool> isFavorite(String businessId);
}

class BusinessLocalDataSourceImpl implements BusinessLocalDataSource {
  final Map<String, BusinessModel> _businessesCache = {};

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_businessesCache.isEmpty) {
      _loadMockBusinesses();
    }

    return _businessesCache.values.toList();
  }

  @override
  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final allBusinesses = await getBusinesses();

    if (category == 'Tout') {
      return allBusinesses;
    }

    final businessType = _mapCategoryToBusinessType(category);
    return allBusinesses
        .where((business) => business.type == businessType)
        .toList();
  }

  BusinessType _mapCategoryToBusinessType(String category) {
    switch (category) {
      case 'Restaurants':
        return BusinessType.restaurant;
      case 'Fast Food':
        return BusinessType.fastFood;
      case 'Shopping':
        return BusinessType.shopping;
      case 'Centres Commerciaux':
        return BusinessType.mall;
      case 'Hôtels':
        return BusinessType.hotel;
      case 'Location Voiture':
        return BusinessType.carRental;
      case 'Détente':
        return BusinessType.detente;
      case 'Voyage' :
        return BusinessType.travelAgency;
      case 'Spa' :
        return BusinessType.spa;
      default:
        return BusinessType.restaurant;
    }
  }

  @override
  Future<BusinessModel> getBusinessDetail(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_businessesCache.containsKey(businessId)) {
      return _businessesCache[businessId]!;
    }

    final business = _getAllMockBusinesses().firstWhere(
      (b) => b.id == businessId,
      orElse: () => throw Exception('Business not found'),
    );

    _businessesCache[businessId] = business;
    return business;
  }

  @override
  Future<List<BusinessModel>> getSimilarBusinesses(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final currentBusiness = await getBusinessDetail(businessId);
    final allBusinesses = await getBusinesses();

    return allBusinesses
        .where((b) => b.id != businessId && b.type == currentBusiness.type)
        .take(3)
        .toList();
  }

  @override
  Future<void> cacheBusiness(BusinessModel business) async {
    _businessesCache[business.id] = business;
  }

  @override
  Future<void> cacheBusinesses(List<BusinessModel> businesses) async {
    for (final business in businesses) {
      _businessesCache[business.id] = business;
    }
  }

  @override
  Future<void> toggleFavorite(String businessId) async {
    if (_businessesCache.containsKey(businessId)) {
      final business = _businessesCache[businessId]!;
      _businessesCache[businessId] = BusinessModel(
        id: business.id,
        name: business.name,
        address: business.address,
        description: business.description,
        bgImg: business.bgImg,
        rating: business.rating,
        reviewCount: business.reviewCount,
        openingHours: business.openingHours,
        type: business.type,
        phone: business.phone,
        email: business.email,
        website: business.website,
        images: business.images,
        specificData: business.specificData,
        reviews: business.reviews,
        isFavorite: !business.isFavorite,
        latitude: business.latitude,
        longitude: business.longitude,
        stores: business.stores,
      );
    }
  }

  @override
  Future<bool> isFavorite(String businessId) async {
    if (_businessesCache.containsKey(businessId)) {
      return _businessesCache[businessId]!.isFavorite;
    }
    return false;
  }

  void _loadMockBusinesses() {
    final mockBusinesses = _getAllMockBusinesses();
    for (final business in mockBusinesses) {
      _businessesCache[business.id] = business;
    }
  }

  List<BusinessModel> _getAllMockBusinesses() {
    final mallStores = [
      BusinessModel(
        id: "mall_store_1",
        name: "Boutique de Mode Élégante",
        address: "Niveau 1, Allée A, Centre Commercial Kin Plaza",
        description:
            "Lorem ipsum dolor sit amet consectetur adipisicing elit. Perferendis corporis itaque asperiores dolorum obcaecati cum autem, tempore commodi quas, dicta ullam ipsum dignissimos fugit. In debitis provident voluptates quisquam eveniet?",
        bgImg: "assets/f6d0ee99086ea92d96f6a66418921a3f.jpg",
        rating: 4.3,
        reviewCount: 67,
        openingHours: {"Lundi-Dimanche": "10:00-20:00"},
        type: BusinessType.shopping,
        phone: "+243 81 111 2222",
        email: null,
        website: null,
        images: [],
        specificData: {"storeType": "Vêtements", "floor": "Niveau 1"},
        reviews: [],
        isFavorite: false,
        latitude: null,
        longitude: null,
        stores: null,
      ),
      BusinessModel(
        id: "mall_store_2",
        name: "TechZone Électronique",
        address: "Niveau 2, Allée B, Centre Commercial Kin Plaza",
        description:
            "Lorem ipsum dolor sit amet consectetur adipisicing elit. Perferendis corporis itaque asperiores dolorum obcaecati cum autem, tempore commodi quas, dicta ullam ipsum dignissimos fugit. In debitis provident voluptates quisquam eveniet?",
        bgImg: "assets/f71a9320d2cf98b169d7c17e093555be.jpg",
        rating: 4.6,
        reviewCount: 89,
        openingHours: {"Lundi-Dimanche": "10:00-20:00"},
        type: BusinessType.shopping,
        phone: "+243 81 333 4444",
        email: null,
        website: null,
        images: [],
        specificData: {"storeType": "Électronique", "floor": "Niveau 2"},
        reviews: [],
        isFavorite: true,
        latitude: null,
        longitude: null,
        stores: null,
      ),
      BusinessModel(
        id: "mall_store_3",
        name: "Café du Mall",
        address: "Niveau 0, Zone Food Court, Centre Commercial Kin Plaza",
        description:
            "Lorem ipsum dolor sit amet consectetur adipisicing elit. Perferendis corporis itaque asperiores dolorum obcaecati cum autem, tempore commodi quas, dicta ullam ipsum dignissimos fugit. In debitis provident voluptates quisquam eveniet?",
        bgImg: "assets/e401f35382555047e8693daba95bfbf7.jpg",
        rating: 4.1,
        reviewCount: 45,
        openingHours: {"Lundi-Dimanche": "08:00-22:00"},
        type: BusinessType.fastFood,
        phone: "+243 81 555 6666",
        email: null,
        website: null,
        images: [],
        specificData: {"storeType": "Restauration", "floor": "Niveau 0"},
        reviews: [],
        isFavorite: false,
        latitude: null,
        longitude: null,
        stores: null,
      ),
    ];

    return [
      // Restaurants
      BusinessModel(
        id: "1",
        name: "Le Balisier",
        address: "709 Lakin Avenue, Kinshasa",
        description:
            "Restaurant traditionnel offrant une cuisine locale authentique...",
        bgImg: "assets/908afb92beabc178010a04db1073db53.jpg",
        rating: 4.5,
        reviewCount: 127,
        openingHours: {
          "Lundi-Vendredi": "08:00-22:00",
          "Samedi-Dimanche": "09:00-23:00",
        },
        type: BusinessType.restaurant,
        phone: "+243 81 234 5678",
        email: "contact@balisier.cd",
        website: "www.lebalisier.cd",
        images: ["assets/images/balisier.jpg", "assets/images/balisier2.jpg"],
        specificData: {
          "hasDelivery": true,
          "canReserve": true,
          "alcoholAvailable": true,
          "ambiance": "Traditionnelle",
          "menuItemsCount": 45,
          "specialties": [
            "Cuisine locale",
            "Poissons grillés",
            "Plats traditionnels",
          ],
          "menuItems": [
            MenuItem(
              itemName: "Pizza Margherita",
              itemCategory: "Pizza",
              imageUrl: "assets/ceca445df991a3eeaa49861b7cd2db7c.jpg",
              rating: 4.5,
              price: 12.99,
              description:
                  "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Sunt vel illum, neque fugiat et temporibus deleniti sequi esse iusto repellat. Est eligendi aspernatur consequuntur officia quod recusandae consectetur aliquam sunt!",
              ingredients: ["Tomate", "Mozzarella", "Basilic", "Huile d'olive"],
            ),
          ],
        },

        reviews: [],
        isFavorite: false,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      ),

      // Shopping
      BusinessModel(
        id: "2",
        name: "Centre Commercial Kin",
        address: "123 Boulevard du 30 Juin, Kinshasa",
        description: "Grand centre commercial avec de nombreuses boutiques...",
        bgImg: "assets/0eb059aec39a696f1be885bc21256672.jpg",
        rating: 4.2,
        reviewCount: 89,
        openingHours: {"Lundi-Dimanche": "09:00-21:00"},
        type: BusinessType.shopping,
        phone: "+243 81 345 6789",
        email: null,
        website: null,
        images: [],
        specificData: {"parking": true, "wifi": true, "storeCount": 150},
        reviews: [],
        isFavorite: false,
        latitude: null,
        longitude: null,
        stores: null,
      ),

      // Fast Food
      BusinessModel(
        id: "3",
        name: "Cool fasfoode",
        address: "123 Boulevard du 30 Juin, Kinshasa",
        description:
            "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Sunt vel illum, neque fugiat et temporibus deleniti sequi esse iusto repellat. Est eligendi aspernatur consequuntur officia quod recusandae consectetur aliquam sunt!",
        bgImg: "assets/pexels-media-108942.jpeg",
        rating: 3.2,
        reviewCount: 90,
        openingHours: {"Lundi-Dimanche": "09:00-21:00"},
        type: BusinessType.fastFood,
        phone: "+243 81 345 6789",
        email: null,
        website: null,
        images: [],
        specificData: {
          "hasDelivery": true,
          "menuItems": [
            MenuItem(
              itemName: "Pizza Margherita",
              itemCategory: "Pizza",
              imageUrl: "assets/ceca445df991a3eeaa49861b7cd2db7c.jpg",
              rating: 4.5,
              price: 12.99,
              description:
              "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Sunt vel illum, neque fugiat et temporibus deleniti sequi esse iusto repellat. Est eligendi aspernatur consequuntur officia quod recusandae consectetur aliquam sunt!",
              ingredients: ["Tomate", "Mozzarella", "Basilic", "Huile d'olive"],
            ),
          ],
        },
        reviews: [],
        isFavorite: true,
        latitude: null,
        longitude: null,
        stores: null,
      ),

      // Hôtels
      BusinessModel(
        id: "4",
        name: "Hôtel Kin Plaza",
        address: "456 Avenue des Ambassadeurs, Kinshasa",
        description:
            "Hôtel 5 étoiles offrant un hébergement de luxe avec piscine, spa et restaurant gastronomique. Parfait pour les voyages d'affaires et les vacances.",
        bgImg: "assets/bf1ccb9107cd115138773245e27218d7.jpg",
        rating: 4.8,
        reviewCount: 234,
        openingHours: {"Lundi-Dimanche": "00:00-23:59"},
        type: BusinessType.hotel,
        phone: "+243 81 777 8888",
        email: "reservation@kinplaza.cd",
        website: "www.kinplaza.cd",
        images: ["assets/hotel1.jpg", "assets/hotel2.jpg", "assets/hotel3.jpg"],
        specificData: {
          "stars": 5,
          "roomCount": 120,
          "hasPool": true,
          "hasSpa": true,
          "hasGym": true,
          "hasRestaurant": true,
          "hasConferenceRoom": true,
          "hasParking": true,
          "wifi": true,
          "breakfastIncluded": true,
          "roomTypes": [
            {"name": "Chambre Standard", "price": 150.0, "capacity": 2},
            {"name": "Chambre Supérieure", "price": 220.0, "capacity": 2},
            {"name": "Suite Junior", "price": 350.0, "capacity": 3},
            {"name": "Suite Présidentielle", "price": 650.0, "capacity": 4},
          ],
          "amenities": [
            "Piscine",
            "Spa",
            "Salle de sport",
            "Restaurant",
            "Room service",
            "Concierge",
          ],
        },
        reviews: [],
        isFavorite: false,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      ),

      // Centres Commerciaux
      BusinessModel(
        id: "5",
        name: "Kin Plaza Mall",
        address: "789 Avenue du Commerce, Kinshasa",
        description:
            "Le plus grand centre commercial de Kinshasa avec plus de 200 boutiques, un cinéma, une aire de jeux et une variété de restaurants.",
        bgImg: "assets/867c83b8c949f3a6e89d90fa6643df0e.jpg",
        rating: 4.4,
        reviewCount: 156,
        openingHours: {"Lundi-Dimanche": "09:00-21:00"},
        type: BusinessType.mall,
        phone: "+243 81 999 0000",
        email: "info@kinplazamall.cd",
        website: "www.kinplazamall.cd",
        images: ["assets/mall1.jpg", "assets/mall2.jpg", "assets/mall3.jpg"],
        specificData: {
          "totalStores": 200,
          "floors": 4,
          "parkingSpaces": 800,
          "hasCinema": true,
          "hasPlayArea": true,
          "hasFoodCourt": true,
          "wifi": true,
          "security": true,
        },
        reviews: [],
        isFavorite: false,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: mallStores,
      ),

      // Hôtels
      BusinessModel(
        id: "6",
        name: "Riverside Hôtel",
        address: "101 River Road, Kinshasa",
        description:
            "Hôtel boutique élégant avec vue sur le fleuve Congo. Cadre romantique parfait pour les couples et les voyageurs exigeants.",
        bgImg: "assets/653957799bf3aa3bcd16012b507e0132.jpg",
        rating: 4.6,
        reviewCount: 178,
        openingHours: {"Lundi-Dimanche": "00:00-23:59"},
        type: BusinessType.hotel,
        phone: "+243 81 222 3333",
        email: "bookings@riverside.cd",
        website: "www.riversidehotel.cd",
        images: ["assets/hotel4.jpg", "assets/hotel5.jpg"],
        specificData: {
          "stars": 4,
          "roomCount": 80,
          "hasPool": true,
          "hasSpa": false,
          "hasGym": true,
          "hasRestaurant": true,
          "hasConferenceRoom": false,
          "hasParking": true,
          "wifi": true,
          "breakfastIncluded": false,
          "roomTypes": [
            {"name": "Chambre Vue Jardin", "price": 120.0, "capacity": 2},
            {"name": "Chambre Vue Fleuve", "price": 180.0, "capacity": 2},
            {"name": "Suite Romantique", "price": 280.0, "capacity": 2},
          ],
          "amenities": [
            "Piscine",
            "Salle de sport",
            "Restaurant",
            "Bar",
            "Terrasse",
          ],
        },
        reviews: [],
        isFavorite: true,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      ),

      // Location Voiture
      BusinessModel(
        id: "7",
        name: "Kin Car Rental",
        address: "123 Avenue des Voitures, Kinshasa",
        description:
            "Agence de location de véhicules offrant une large gamme de voitures pour tous vos besoins : voyages, affaires, occasions spéciales. Service 24h/24 et livraison possible.",
        bgImg: "assets/pexels-media-10161200.jpeg",
        rating: 4.7,
        reviewCount: 89,
        openingHours: {
          "Lundi-Vendredi": "07:00-20:00",
          "Samedi": "08:00-18:00",
          "Dimanche": "09:00-16:00",
        },
        type: BusinessType.carRental,
        phone: "+243 81 444 5555",
        email: "reservation@kincar.cd",
        website: "www.kincarrental.cd",
        images: ["assets/car1.jpg", "assets/car2.jpg", "assets/car3.jpg"],
        specificData: {
          "fleetSize": 45,
          "vehicleTypes": [
            {
              "type": "Économique",
              "examples": ["Toyota Yaris", "Hyundai i10"],
              "dailyPrice": 35.0,
              "features": ["Climatisation", "4 places", "Consommation réduite"],
            },
            {
              "type": "Compacte",
              "examples": ["Toyota Corolla", "Honda Civic"],
              "dailyPrice": 50.0,
              "features": [
                "Climatisation",
                "5 places",
                "GPS",
                "Siège bébé disponible",
              ],
            },
            {
              "type": "SUV",
              "examples": ["Toyota RAV4", "Nissan X-Trail"],
              "dailyPrice": 75.0,
              "features": ["4x4", "7 places", "Grand coffre", "Toit ouvrant"],
            },
            {
              "type": "Luxe",
              "examples": ["Mercedes Classe C", "BMW Série 3"],
              "dailyPrice": 120.0,
              "features": [
                "Cuir",
                "GPS premium",
                "Caméra de recul",
                "Assistance complète",
              ],
            },
            {
              "type": "Minibus",
              "examples": ["Toyota Hiace", "Mercedes Vito"],
              "dailyPrice": 90.0,
              "features": ["9 places", "Grand espace", "Idéal groupes"],
            },
          ],
          "services": [
            "Livraison véhicule",
            "Service 24h/24",
            "Assurance complète",
            "Sièges bébé",
            "GPS",
            "Conducteur supplémentaire",
          ],
          "requirements": [
            "Permis de conduire valide",
            "Carte d'identité",
            "Caution (variable)",
            "Âge minimum: 21 ans",
          ],
          "deliveryAvailable": true,
          "insuranceIncluded": true,
          "unlimitedMileage": true,
          "additionalDrivers": true,
        },
        reviews: [
          BusinessReview(
            id: "rev_car_1",
            userName: "Jean K.",
            userAvatar: "https://example.com/avatar1.jpg",
            rating: 5.0,
            comment:
                "Service excellent ! Voiture propre et en parfait état. Processus de réservation très simple.",
            date: DateTime.now().subtract(const Duration(days: 15)),
            likes: 12,
            commentCount: 3,
          ),
          BusinessReview(
            id: "rev_car_2",
            userName: "Marie L.",
            userAvatar: "https://example.com/avatar2.jpg",
            rating: 4.5,
            comment:
                "Location pour un mariage, tout s'est parfaitement passé. Je recommande !",
            date: DateTime.now().subtract(const Duration(days: 30)),
            likes: 8,
            commentCount: 1,
          ),
        ],
        isFavorite: false,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      ),

      // Location Voiture
      BusinessModel(
        id: "8",
        name: "Premium Drive Kinshasa",
        address: "456 Boulevard de l'Automobile, Gombe",
        description:
            "Location de véhicules de luxe et prestige pour événements spéciaux, entreprises et particuliers exigeants. Service haut de gamme avec chauffeur optionnel.",
        bgImg: "assets/pexels-media-10161200.jpeg",
        rating: 4.9,
        reviewCount: 45,
        openingHours: {"Lundi-Dimanche": "06:00-22:00"},
        type: BusinessType.carRental,
        phone: "+243 81 777 8888",
        email: "premium@premiumdrive.cd",
        website: "www.premiumdrive.cd",
        images: ["assets/premium1.jpg", "assets/premium2.jpg"],
        specificData: {
          "fleetSize": 25,
          "premium": true,
          "vehicleTypes": [
            {
              "type": "Berline Premium",
              "examples": ["Mercedes Classe E", "BMW Série 5"],
              "dailyPrice": 200.0,
              "features": [
                "Intérieur cuir",
                "Système audio premium",
                "Assistance conduite",
              ],
            },
            {
              "type": "SUV Luxury",
              "examples": ["Range Rover Sport", "Mercedes GLE"],
              "dailyPrice": 300.0,
              "features": [
                "4x4 permanent",
                "Toit panoramique",
                "Système multimédia avancé",
              ],
            },
            {
              "type": "Voiture de Sport",
              "examples": ["Porsche 911", "Audi R8"],
              "dailyPrice": 500.0,
              "features": [
                "Performance élevée",
                "Design sportif",
                "Expérience conduite unique",
              ],
            },
            {
              "type": "Voiture de Collection",
              "examples": ["Vintage Mercedes", "Classique American"],
              "dailyPrice": 400.0,
              "features": [
                "Modèle unique",
                "Parfait événements",
                "Attention particulière",
              ],
            },
          ],
          "services": [
            "Service avec chauffeur",
            "Livraison sur rendez-vous",
            "Service concierge",
            "Nettoyage quotidien",
            "Assurance tous risques",
            "Assistance VIP",
          ],
          "requirements": [
            "Permis valide + 3 ans d'expérience",
            "Passeport ou carte d'identité",
            "Caution importante",
            "Âge minimum: 25 ans",
            "Vérification antécédents",
          ],
          "deliveryAvailable": true,
          "insuranceIncluded": true,
          "unlimitedMileage": true,
          "additionalDrivers": false,
          "chauffeurService": true,
        },
        reviews: [],
        isFavorite: true,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      ),

      // Détente
      BusinessModel(
        id: "9",
        name: "Spa Oasis Relax",
        address: "789 Avenue de la Paix, Kinshasa",
        description:
            "Centre de bien-être et spa offrant des soins relaxants, des massages thérapeutiques et des soins esthétiques dans un cadre paisible et luxueux.",
        bgImg: "assets/spa_oasis.jpg",
        rating: 4.7,
        reviewCount: 92,
        openingHours: {
          "Lundi-Samedi": "09:00-20:00",
          "Dimanche": "10:00-18:00",
        },
        type: BusinessType.detente,
        phone: "+243 81 888 9999",
        email: "info@spaoasis.cd",
        website: "www.spaoasis.cd",
        images: ["assets/spa1.jpg", "assets/spa2.jpg", "assets/spa3.jpg"],
        specificData: {
          "services": [
            "Massage suédois",
            "Massage aux pierres chaudes",
            "Soin du visage",
            "Enveloppement corporel",
            "Sauna",
            "Hammam",
          ],
          "therapists": 8,
          "treatmentRooms": 6,
          "hasSauna": true,
          "hasSteamRoom": true,
          "hasJacuzzi": true,
          "hasChangingRooms": true,
          "hasParking": true,
          "wifi": true,
          "priceRange": "Moyen à élevé",
          "packages": [
            {
              "name": "Découverte",
              "duration": "1h",
              "price": 50.0,
              "includes": ["Massage", "Accès sauna"],
            },
            {
              "name": "Relaxation",
              "duration": "2h",
              "price": 90.0,
              "includes": ["Massage", "Soin visage", "Accès hammam"],
            },
            {
              "name": "Journée bien-être",
              "duration": "4h",
              "price": 180.0,
              "includes": [
                "Massage",
                "Soin complet",
                "Déjeuner",
                "Accès toutes installations",
              ],
            },
          ],
          "specialties": [
            "Massage thérapeutique",
            "Soins anti-stress",
            "Détente profonde",
          ],
        },
        reviews: [
          BusinessReview(
            id: "rev_spa_1",
            userName: "Sophie M.",
            userAvatar: "https://example.com/avatar3.jpg",
            rating: 5.0,
            comment:
                "Un havre de paix incroyable. Le personnel est attentionné et les soins sont exceptionnels.",
            date: DateTime.now().subtract(const Duration(days: 20)),
            likes: 15,
            commentCount: 5,
          ),
          BusinessReview(
            id: "rev_spa_2",
            userName: "David T.",
            userAvatar: "https://example.com/avatar4.jpg",
            rating: 4.5,
            comment:
                "Parfait pour se détendre après une longue semaine de travail. Je recommande le massage aux pierres chaudes!",
            date: DateTime.now().subtract(const Duration(days: 45)),
            likes: 9,
            commentCount: 2,
          ),
        ],
        isFavorite: false,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      ),

      // Détente
      BusinessModel(
        id: "10",
        name: "Parc des Palmiers",
        address: "234 Boulevard de la Rivière, Kinshasa",
        description:
            "Parc récréatif et espace vert idéal pour les pique-niques en famille, les promenades et les activités de plein air. Parfait pour échapper à l'agitation de la ville.",
        bgImg: "assets/palmiers_park.jpg",
        rating: 4.3,
        reviewCount: 67,
        openingHours: {"Tous les jours": "06:00-20:00"},
        type: BusinessType.detente,
        phone: "+243 81 666 7777",
        email: "contact@parcpalmiers.cd",
        website: "www.parcpalmiers.cd",
        images: ["assets/park1.jpg", "assets/park2.jpg", "assets/park3.jpg"],
        specificData: {
          "area": "5 hectares",
          "activities": [
            "Pique-nique",
            "Promenade",
            "Jogging",
            "Aire de jeux",
            "Événements culturels",
          ],
          "facilities": [
            "Toilettes",
            "Bancs",
            "Fontaines à eau",
            "Éclairage",
            "Parking",
          ],
          "hasPlayground": true,
          "hasPicnicTables": true,
          "hasWalkingPaths": true,
          "hasBikeRental": true,
          "entryFee": false,
          "guidedTours": true,
          "events": [
            "Concerts du dimanche",
            "Marché artisanal",
            "Yoga en plein air",
          ],
          "accessibility": true,
          "petFriendly": true,
        },
        reviews: [],
        isFavorite: true,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      ),

      BusinessModel(
        id: "11",
        name: "Voyages Express",
        address: "123 Avenue du voyage, Kinshasa",
        description: "Agence spesialiée dans les trajets en bus vers toutes les provinces. Confort et securité farnatis.",
        bgImg: "bgImg",
        rating: 4.5,
        reviewCount: 56,
        openingHours: {"Lundi-venderedi": "08:00-18:00", "Samedi": "09:00-15:00"},
        type: BusinessType.travelAgency,
        phone: "000 000 0000",
        images: [],
        specificData: {
          "canReserve": true,
          "destinations":[
            {"name": "Matadi", "price": 25.0, "duration": "5h"},
            {"name": "Kikwit", "price": 30.0, "duration": "8h"},
            {"name": "Lumbubashi", "price": 80.0, "duration": "24h"},
          ],
          "services": ["Wifi", "Climatisation", "Pris de rechearge", "Bagages inclus"],
          "departureTimes": ["06:00", "09:00", "14:00", "18:00"],
        },
        reviews: [

        ],
        isFavorite: false,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      ),

      BusinessModel(
        id: "12",
        name: "Spa Détente & Bien-être",
        address: "456 Avenue de la Relaxation, Kinshasa",
        description: "Un havre de paix offrant des soins de qualité, massages, hammam et soins du visage dans un cadre apaisant.",
        bgImg: "assets/spa_cover.jpg",
        rating: 4.8,
        reviewCount: 120,
        openingHours: {"Lundi-Samedi": "09:00-20:00", "Dimanche": "10:00-18:00"},
        type: BusinessType.spa,
        phone: "+243 81 123 4567",
        email: "contact@spa.cd",
        website: "www.spa.cd",
        images: ["assets/spa1.jpg", "assets/spa2.jpg"],
        specificData: {
          "canReserve": true,
          "treatments": [
            {"name": "Massage relaxant", "duration": 60, "price": 50.0, "description": "Massage aux huiles essentielles pour détendre les muscles."},
            {"name": "Massage aux pierres chaudes", "duration": 90, "price": 80.0, "description": "Massage profond avec des pierres volcaniques chaudes."},
            {"name": "Soin du visage", "duration": 45, "price": 40.0, "description": "Nettoyage, gommage et masque adapté à votre peau."},
            {"name": "Hammam & Gommage", "duration": 60, "price": 55.0, "description": "Séance de hammam suivie d'un gommage au savon noir."},
            {"name": "Forfait Bien-être", "duration": 120, "price": 130.0, "description": "Massage relaxant + soin du visage + accès hammam."},
          ],
          "therapists": [
            {"name": "Sophie", "specialty": "Massages"},
            {"name": "Marc", "specialty": "Soins du visage"},
            {"name": "Julie", "specialty": "Hammam & Gommage"},
          ],
          "amenities": ["Hammam", "Sauna", "Jacuzzi", "Espace détente"],
        },
        reviews: [],
        isFavorite: false,
        latitude: -4.4419,
        longitude: 15.2663,
        stores: null,
      )
    ];
  }
}
