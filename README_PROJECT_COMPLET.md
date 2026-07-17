# 🍽️ Baobabe — Application de commande & réservation (MVP restauration)

**Baobabe** est une application mobile (Flutter, multiplateforme) pensée pour aider les utilisateurs à **trouver des restaurants / fast-foods**, **consulter leurs menus**, **commander** et **réserver**.

Ce n’est **pas** un projet d’e-commerce : il ne s’agit pas d’une boutique en ligne avec “produits à acheter”. L’objectif est de connecter des **commerces de restauration** à leurs clients via une expérience mobile simple.

> ⚠️ Le projet est actuellement en **phase MVP** : on travaille en priorité sur les **restaurants et fast-foods** afin de valider le besoin réel et d’itérer vite.
> D’autres types d’établissements pourront être ajoutés **progressivement** ensuite (au fur et à mesure des retours et de l’évolution produit).

---

## 🎯 Vision produit (MVP)
- Permettre aux utilisateurs de découvrir facilement des établissements.
- Offrir un parcours fluide pour **voir le menu**.
- Faciliter **la commande à emporter / livraison** (selon les cas).
- Permettre **la réservation** (choix de date/heure/couverts, selon le modèle).
- Mettre en place une base solide côté backend pour l’itération (auth, commandes, réservations, gestion menu).

---

## ✨ Fonctionnalités couvertes

### 1) Authentification
- Inscription et connexion.
- Gestion de session via **tokens JWT** (access + refresh).

### 2) Découverte des commerces
- Liste des établissements.
- Accès aux informations d’un établissement.
- (Selon l’implémentation) récupération des éléments liés au commerce, comme le **menu**.

### 3) Menu
- Récupération des items du menu (organisés par catégories côté backend).
- Affichage côté client (Flutter).

### 4) Commandes
- Création de commande avec :
  - utilisateur
  - établissement
  - liste des items (quantités, prix unitaires)
  - frais de livraison (si applicable)
  - moyen de paiement
  - notes / instructions
- Statuts de commande (logique présente dans l’API backend) : **pending, confirmed, preparing, ready, delivered, cancelled**.

### 5) Réservation
- Création de réservation (avec un champ `type` et des `details`).
- Récupération et suppression côté API.

### 6) Espace “commerçant” / dashboard (en cours)
- Routes protégées (middleware `isBusinessOwner`).
- Statistiques et ventes par produit.
- Gestion :
  - ajout d’articles au menu
  - mise à jour prix / disponibilité
- Gestion des commandes et informations utiles au commerçant.

---

## 🧩 Ce que n’est pas Baobabe
- Ce n’est **pas** une marketplace ni une boutique e-commerce.
- L’application ne vise pas à vendre des produits physiques “standard” avec panier comme une boutique en ligne.
- La logique principale est centrée sur la **restauration** : menus, commandes, réservations et pilotage côté commerces.

---

## 🛠️ Stack technique

### Frontend
- **Flutter** (Dart) — mobile + web
- Gestion d’état : `flutter_bloc` + `equatable`
- Navigation : `go_router`
- Requêtes réseau : `dio` (avec logique tokens)
- Stockage sécurisé : `flutter_secure_storage`
- Graphiques : `fl_chart`

### Backend (API REST)
- **Node.js** + **Express**
- **PostgreSQL** (`pg`)
- Auth JWT : access + refresh tokens
- Middleware : contrôle commerçant (`isBusinessOwner`)
- Docker / Docker Compose (en environnement de développement)

---

## 📦 Endpoints / API (vue d’ensemble)
- `api/auth` : signup, login, refresh, verify, me, logout
- `api/businesses` : liste / détail / menu (et endpoints dashboard)
- `api/orders` : création, récupération, mise à jour statut
- `api/reservations` : création, récupération, suppression
- `api/vehicles` : présent (mais non prioritaire pour le MVP restauration)
- D’autres routes existent également (comments/reviews/sales_by_product), pour enrichir la base produit.

---

## 🚀 Installation & lancement (dev)
### Prérequis
- Flutter SDK
- Node.js + npm
- PostgreSQL
- Docker (optionnel, pour le backend)

### Backend
1. Aller dans `backend/`
2. Configurer les variables d’environnement (dont `JWT_SECRET`, et éventuellement `REFRESH_TOKEN_SECRET`)
3. Lancer le serveur Node.js.

### Frontend
1. Lancer l’application Flutter
2. Configurer l’URL API côté client si nécessaire.

---

## 🗺️ Roadmap (approche MVP → itérations)
- Continuer à renforcer le socle restauration : commandes, réservations, menu.
- Améliorer l’espace commerçant (dashboard) : statistiques, gestion menu, flux commandes.
- Ajouter des briques progressivement au fur et à mesure des besoins (UX, performance, nouveaux cas d’usage).

---

## 🤝 Remarque de fond
Ce projet est construit pour **itérer rapidement**. On privilégie un MVP solide sur la **restauration** afin d’obtenir des retours terrain, puis on étendra progressivement à d’autres catégories de commerces.

