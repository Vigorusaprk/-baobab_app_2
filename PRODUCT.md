# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

Baobabe est une application Flutter livrée depuis un seul code source vers
Android, iOS et le navigateur. La valeur `web` n'est pas un raccourci : le
produit porte **un seul langage visuel**, le sien, sur les trois cibles, et
n'adapte pas son design par système d'exploitation. Les conventions iOS ou
Material ne s'appliquent donc pas — mais toute interface doit tenir depuis la
largeur d'un téléphone jusqu'à celle d'un écran de bureau.

## Users

Deux publics comptent également ; aucun ne l'emporte dans un arbitrage.

- **L'habitant de Kinshasa**, qui connaît déjà une partie de sa ville et veut
  trouver vite puis commander ou réserver sans passer un appel.
- **Le visiteur ou le membre de la diaspora**, qui ne connaît pas ou plus les
  adresses et a besoin de se repérer et de faire confiance avant de choisir.

Un troisième rôle vit dans la même application : **le commerçant**, qui publie
son catalogue et traite ce qu'il reçoit. Devenir commerçant change entièrement
l'interface — ce n'est pas un onglet de plus mais une autre application, sans
que le compte cesse de pouvoir commander ailleurs.

## Product Purpose

Mettre en relation les habitants et visiteurs de Kinshasa avec les commerces
de la ville : découvrir une offre, puis la commander, la réserver, ou savoir
qu'il faut passer en boutique. Le succès se mesure à une transaction menée à
son terme des deux côtés — le client obtient ce qu'il a demandé, le commerçant
voit la demande arriver et y répond.

Ce n'est pas un site d'e-commerce : rien n'est vendu par la plateforme, qui
met en relation.

## Positioning

**Un seul moule pour tous les commerces.** Un plat, une chambre, un soin, un
concert, un cosmétique sont la même chose vue du produit : une offre, avec une
seule distinction structurante — elle se **commande**, elle se **réserve**, ou
elle est **disponible en boutique**.

Ce que cela permet et qu'un concurrent ne peut pas recopier sans réécrire son
socle : n'importe quel commerçant, de n'importe quel métier, publie et vend
sans qu'on écrive une ligne de code pour sa catégorie. Ce qu'un commerce
permet de faire n'est jamais déduit de son type mais des offres qu'il a
réellement publiées — ce qui évite à la fois les catégories sans aucune action
possible et les boutons qui ne mènent nulle part.

## Operating Context

- **Kinshasa, République démocratique du Congo.** Adresses, indicatifs
  téléphoniques `+243`, prix en dollars américains.
- **Français en langue principale**, avec anglais et lingala pris en charge.
- Réseau irrégulier : le catalogue déjà consulté doit rester lisible hors
  ligne, et une écriture qui échoue ne doit jamais être présentée comme
  réussie.
- Beaucoup de commerçants visés n'ont ni site ni logiciel de gestion :
  l'application est parfois leur seule vitrine et leur seul carnet de
  commandes.
- Le paiement se règle **hors de l'application**, sur place ou à la
  livraison.

## Capabilities and Constraints

**Ce qui existe et fonctionne**

- Découverte sans compte : catalogue, fiches, offres et avis sont lisibles par
  un visiteur anonyme. La connexion est demandée au moment d'agir, jamais pour
  naviguer.
- Trois sections d'accueil, filtrables par catégorie : Nouveautés (offres de
  moins de 30 jours), Populaires (les 3 meilleurs commerçants), Découvrir (les
  offres les mieux notées).
- Catégories servies par le back-end et mises en cache : en ajouter une ne
  demande pas de publier une version.
- Commande (panier, quantités) et réservation (une offre, une quantité, une
  date, une jauge de places).
- Statuts de commande : `pending`, `confirmed`, `preparing`, `ready`,
  `delivered`, `cancelled`. Statuts de réservation : `pending`, `confirmed`,
  `cancelled`, `completed`. Une réservation naît **en attente** : le
  commerçant doit la confirmer.
- Notation : on note **une offre**, jamais directement un commerce. La note du
  commerçant est la moyenne de celles de ses offres.
- Espace commerçant : demande d'ouverture, publication et retrait d'offres,
  commandes et réservations reçues avec le nom du client, changement de
  statut, chiffres du tableau de bord.

**Contraintes durables**

- **Le serveur fait autorité sur l'argent.** Le client n'envoie jamais un prix
  ni un total : il envoie des identifiants d'offres et des quantités.
- Une offre se **retire** (`is_active = false`), elle ne se supprime pas : les
  commandes passées la référencent, et un historique qui perd le nom de ce qui
  a été acheté ne vaut plus rien.
- Un commerçant ne publie que sous son propre commerce, déterminé côté serveur
  à partir de son rôle — jamais depuis la requête.
- Terminologie : **offre** (ce qui est publié), **commerçant** (celui qui
  publie), **commerce** (l'enseigne), **activités** (l'historique du client).

**Explicitement non décidé / absent**

- **Le paiement en ligne n'existe pas** et a été volontairement reporté.
- **Il n'y a pas de panneau d'administration.** Une demande de compte
  commerçant est donc acceptée automatiquement, avec la mention
  « Acceptation automatique en attendant le panneau d'administration ». Les
  trois états (`pending`, `approved`, `rejected`) existent déjà côté client
  pour que la modération n'impose aucune reprise d'interface.
- Pas de critère de popularité mesuré (ni vues ni volume de commandes) : le
  classement « Populaires » s'appuie sur la note, en attendant mieux.
- Pas de géolocalisation ni de distance affichée.
- Un compte ne gère qu'un seul commerce.

## Brand Commitments

- Le nom **Baobabe**.
- Le français comme langue de l'interface ; le lingala est une langue prise en
  charge, pas un ornement.
- Le système visuel existant est contraignant : `AppTheme.silvaTheme` est
  l'unique source de vérité pour le thème, et toute couleur, tout espacement,
  toute typographie passe par `AppColors`, `AppDimens`, `AppFonts`. Un seul
  thème, clair. Aucune valeur littérale en dur.
- Un chargement se montre avec un squelette reprenant la forme du contenu à
  venir, jamais avec un indicateur circulaire — sauf sur un bouton en action.

## Evidence on Hand

- 33 commerces et 98 offres en base, **inspirés de commerces réels de
  Kinshasa** dont les informations ont été recherchées en ligne. Ces données
  sont réalistes mais **ne résultent d'aucun partenariat** : rien ne doit être
  présenté comme une enseigne partenaire, un client ou une référence.
- Aucun témoignage, aucun chiffre d'usage, aucune étude, aucune mention presse
  n'existe. Ne pas en inventer.
- Le tarif, le modèle économique et les conditions faites aux commerçants ne
  sont pas définis.
- `.agents/AGENTS.md` tient la mémoire technique et les règles de
  contribution ; les fichiers `README*.md` décrivent une version antérieure
  du produit (MVP restauration, panier, authentification maison) et **ne sont
  plus fiables**.

## Product Principles

1. **Un seul moule, jamais une table par métier.** Ce qu'un commerce permet
   se déduit de ses offres, pas de sa catégorie.
2. **Ne rien promettre qu'on ne tient pas.** Pas de bouton sans destination,
   pas de section vide annoncée, pas de « confirmé » quand c'est « en
   attente ». Une section sans contenu disparaît.
3. **Le serveur est l'autorité sur l'argent et la disponibilité.** Le client
   affiche, il ne décide pas.
4. **On regarde avant de se connecter.** L'inscription se demande au moment
   d'agir, jamais pour explorer.
5. **L'historique est intouchable.** Ce qui a été commandé garde son nom et
   son prix, même quand l'offre disparaît du catalogue.

## Accessibility & Inclusion

Aucune norme n'a été formellement retenue à ce stade. Deux besoins sont
avérés par le contexte et doivent être respectés :

- **Le multilinguisme** (français, anglais, lingala) : aucun texte ne doit
  être figé dans une largeur qui ne survivrait pas à une traduction plus
  longue.
- **Le réseau et le matériel modestes** : l'application doit rester utilisable
  sur un téléphone d'entrée de gamme et une connexion intermittente.
