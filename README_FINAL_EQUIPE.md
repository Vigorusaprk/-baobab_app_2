# 🍽️ Baobabe — Application de commande & réservation (projet équipe)

Baobabe est une application mobile **multiplateforme** (Flutter) conçue pour aider les utilisateurs à **découvrir des établissements**, consulter leurs informations et accéder à des parcours de **réservation** et de **commande / opérations** selon le type de commerce.

Ce projet est **volontairement différent d’un e-commerce** : nous ne cherchons pas à vendre des produits physiques via un panier. La logique centrale est de **mettre en relation des clients avec des acteurs locaux** via une expérience mobile claire et orientée “services”.

> ⚠️ Contexte actuel : le projet est en **phase MVP**. L’implémentation prioritaire est partie des usages “restauration” (restaurants & fast-foods) pour valider le besoin et itérer vite.
> Mais l’application est pensée comme une base **holistique** : d’autres types de commerces sont déjà modélisés (ex. cinéma, mall/centres avec magasins, hébergement) et pourront être activés progressivement selon les besoins.


---

## 🎯 Objectif du projet (au-delà du MVP)
Baobabe a été pensée comme une base évolutive. L’équipe utilise ce socle pour :

- construire une expérience utilisateur cohérente autour de plusieurs types de services (restauration, hébergement, loisirs, etc.) ;
- industrialiser l’API (auth, gestion des commerces, commandes, réservations, etc.) ;
- permettre au “business” de gérer son catalogue et ses opérations ;
- préparer des ajouts futurs (autres catégories, nouveaux parcours, enrichissements métier) sans tout réécrire.

En clair : ce n’est pas uniquement une appli “pour commander”, mais une plateforme **orientée usages de commerces**.

---

## ✨ Ce que fait Baobabe (vision produit)

### 1) Authentification & sessions
- Inscription, connexion.
- Gestion de session via **tokens JWT** (access + refresh).

### 2) Découverte des commerces (multi-types)
- Liste des établissements (selon leur catégorie / type).
- Accès aux informations détaillées d’un établissement.
- Récupération et affichage des éléments associés au type de commerce (ex. menu pour la restauration, ressources spécifiques pour d’autres catégories).


### 3) Consultation du menu
- Menu structuré (catégories gérées côté backend).
- Affichage côté client : plats, informations, et organisation pour faciliter la décision.

### 4) Commandes & opérations (selon le type de commerce)
- Création d’une commande avec :
  - l’utilisateur
  - l’établissement
  - la liste des items (quantités, prix unitaires)
  - les informations de paiement
  - les notes/instructions (si besoin)
  - des frais éventuels (ex. options spécifiques selon le commerce)
- Suivi d’un cycle de statut (logique présente côté API backend) :
  - **pending, confirmed, preparing, ready, delivered, cancelled**


### 5) Réservation
- Création de réservation avec un champ `type` et un objet `details`.
- Récupération et suppression via l’API.

### 6) Espace “commerçant” (projet à part)
L’espace commerçant sera livré sous forme d’un produit/une application distincte (projet séparé) : navigation, écrans et droits business.

Actuellement, le backend expose déjà les routes et la logique nécessaires pour supporter cet espace.


- Routes protégées (middleware **isBusinessOwner**).
- Gestion du menu : ajout et mise à jour d’articles.
- Gestion/préparation côté commandes et informations utiles au commerçant.
- Statistiques & ventes par produit (dashboard / analytics côté business).

---

## 🧩 Ce que Baobabe n’est pas
- Ce n’est **pas** une marketplace.
- Ce n’est **pas** une boutique en ligne type e-commerce avec un catalogue de produits physiques “à acheter”.
- Le panier / la logique de sélection sert un objectif de **restauration** : commander des plats, suivre l’avancement, gérer des réservations.

---

## 🧱 Stack technique (pour l’équipe)

### Frontend — Flutter (mobile + web)
- Flutter (Dart) **multiplateforme**
- State management : `flutter_bloc` + `equatable`
- Navigation : `go_router` (shell client / zones business)
- Requêtes réseau : `dio` (avec logique de tokens)
- Stockage sécurisé : `flutter_secure_storage`
- (Autres dépendances possibles selon les écrans / besoins)

### Backend — Supabase
- **Supabase** gère la couche backend (auth, données, policies) via son écosystème.
- Auth (session) et accès contrôlé selon les rôles (ex. business).
- Base de données et opérations via Supabase.



---

## 🚀 Roadmap (approche “itération continue”)

### Phase actuelle : MVP & itérations
- Consolider les parcours “établissement → ressources spécifiques → commande/réservation”.
- Renforcer la base backend : statuts, sécurité, modèles de données.
- Développer progressivement l’espace commerçant pour gérer ses ressources et opérations.


### Prochaines itérations
- Amélioration UX et performance.
- Stabilisation des workflows business.
- Enrichissements : statistiques plus complètes, fonctionnalités additionnelles, écrans spécifiques.

### Extension à d’autres catégories
- Ajouter **progressivement** d’autres types d’établissements au fur et à mesure des retours.
- L’architecture est pensée pour supporter l’évolution sans casser l’existant.

---

## 🛠️ Installation (repères pour l’équipe)

### Prérequis
- Flutter SDK
- (facultatif) Node.js/npm
- PostgreSQL (si utilisé dans l’écosystème)

- Docker (optionnel, utile pour le backend)

### Backend
- Configurer Supabase (projet, auth, database, policies).
- Utiliser les variables/paramètres nécessaires côté application (URL Supabase, clés, etc.).


### Frontend
1. Lancer l’application Flutter
2. Configurer l’URL API si nécessaire côté client

---

## 🧠 Remarque de fond (culture projet)
Baobabe a été construit pour **itérer rapidement**. L’objectif n’est pas de viser une “version parfaite” dès le départ, mais de :

1. livrer un MVP utile sur la restauration ;
2. récolter des retours ;
3. améliorer et étendre progressivement le produit.

Ce document sert de référence d’ensemble pour l’équipe, afin de garder la cohérence produit/technique sur l’ensemble du cycle de vie du projet.

