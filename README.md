# 🍽️ Baobabe – Application de commande et réservation pour restaurants et fast-foods

Baobabe est une application mobile multiplateforme (Flutter) qui permet aux utilisateurs de découvrir des restaurants et fast‑foods locaux, de consulter leurs menus, de passer des commandes à emporter ou en livraison, et de réserver une table. L’application est actuellement en phase **MVP** et se concentre exclusivement sur la **restauration** afin de tester le marché et d’itérer rapidement.

> 🚧 Version actuelle : **focus sur les restaurants & fast‑foods**. D’autres types de commerces (hôtels, spas, locations de voitures) seront intégrés ultérieurement.

## ✨ Fonctionnalités principales

- **Authentification** : inscription, connexion, gestion de session (tokens JWT).
- **Découverte des commerces** : liste filtrée par catégorie, recherche par nom ou adresse.
- **Consultation du menu** : affichage par catégories, images, prix, descriptions.
- **Panier** : ajout de plats, modification des quantités, validation de la commande.
- **Commandes** : suivi du statut (en attente, confirmée, prête, livrée).
- **Réservation de table** : choix de la table, date, heure, nombre de couverts.
- **Espace commerçant (dashboard)** : gestion des commandes, des réservations et du menu (en cours de développement).
- **Responsive** : interface adaptée aux mobiles, tablettes et web.

## 🛠️ Stack technique

### Frontend (mobile & web)
- [Flutter](https://flutter.dev) 3.x (Dart)
- **State management** : `flutter_bloc` + `equatable`
- **Navigation** : `go_router` (shell client et business)
- **HTTP client** : `dio` (avec interception des tokens)
- **Stockage local sécurisé** : `flutter_secure_storage`
- **QR codes** : `qr_flutter`
- **Graphiques** : `fl_chart` (pour le dashboard business)

### Backend (API REST)
- **Serveur** : Node.js (Express)
- **Base de données** : PostgreSQL (avec `pg` driver)
- **Authentification** : JWT (access + refresh tokens)
- **Sécurité** : bcrypt pour les mots de passe, middleware personnalisé
- **Endpoints principaux** :
    - `api/auth` : inscription, connexion, rafraîchissement token
    - `api/businesses` : liste, détail, menu, disponibilités
    - `api/orders` : création, récupération, mise à jour du statut
    - `api/reservations` : création, suppression, filtrage
    - `api/vehicles` (prochainement)

### Déploiement
- **Conteneurisation** : Docker / Docker Compose (environnement de développement)
- **Future** : VPS (Hetzner, DigitalOcean) avec reverse proxy Nginx

## 📦 Installation

### Prérequis
- Flutter SDK (≥ 3.0)
- Node.js (≥ 18) et npm
- PostgreSQL (≥ 14)
- Docker (optionnel, pour l’environnement backend)

### 1. Cloner le dépôt
```bash
git clone https://github.com/votre-username/baobabe.git
cd baobabe