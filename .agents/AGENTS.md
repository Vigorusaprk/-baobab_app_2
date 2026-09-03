# AGENTS.md

## Purpose

This file gives any AI agent or developer a practical map of the Baobab project.
It explains the product, the architecture, the data flow, the backend expectations, and the rules every agent must follow when touching this codebase.

Read this file before modifying the app. Skills installed under `.agents/skills/` (Flutter/Dart architecture, testing, layout, routing, localization, JSON serialization, package management) should be consulted when the task at hand matches their description.

## Product Summary

Baobab (package name `baobabe_0_2`) is a Flutter mobile application for discovering and booking local businesses (hotels, restaurants, car rentals, travel agencies, spas, cinemas, tourism activities, boutiques/malls) with an integrated cart/order flow.

Core user value:

- browse and search businesses by category
- view business detail pages with type-specific sections (menu, rooms, showtimes, treatments, activities, vehicles, products)
- make reservations (hotel rooms, restaurant tables, car rentals, travel bookings, spa treatments, cinema tickets, tourism activities)
- order food/products through a cart and checkout flow
- track past orders and reservations ("favorites"/bookings)
- manage a user profile and app settings (theme, language)
- authenticate via email OTP, Google, or Apple through Supabase Auth

## Architecture Overview

The project uses a feature-driven structure with BLoC/Cubit state management (`flutter_bloc`) and a data/domain/presentation split per feature.

Main layout:

- `lib/core` — shared constants, themes, routing, services, error types, widgets
- `lib/features/auth` — authentication (email OTP, Google, Apple via Supabase)
- `lib/features/home_page` — business discovery, categories, search
- `lib/features/business_detail` — business detail screen and all type-specific booking/ordering flows (`presentation/widgets/online_order/`)
- `lib/features/booking_page` — reservation history ("favorites")
- `lib/features/order` — order history and order detail
- `lib/features/settings` — profile, theme, language, logout
- `lib/features/main` — app shell (bottom navigation, backgrounds)

Layer intent:

- **data**: models, remote data sources (Supabase), repository implementations
- **domain**: entities, repository contracts, usecases
- **presentation**: screens, widgets, blocs/cubits, events, states

## Dependency Wiring — No Service Locator

**There is no `get_it`/service-locator/DI container in this project, and none should be reintroduced.** A previous `lib/core/constants/injector.dart` (get_it based) was removed because it was out of sync with the actual codebase and crashed the app at startup (it referenced usecases and an `AuthBloc` constructor that no longer existed).

Current pattern: **construct dependencies directly where they're needed.**

- App-wide blocs (`AuthBloc`, `CategoryBloc`, `BusinessBloc`, `MainScreenBloc`, `SearchBloc`, `SettingsCubit`) are constructed once in `lib/main.dart` inside `MultiBlocProvider` and reused via `context.read<T>()`/`BlocProvider.value` down the tree.
- Screen-scoped blocs (e.g. `BusinessDetailBloc`, which requires a specific `businessId`) are constructed locally where the screen is built (see `business_detail_screen.dart`), not at the app root.
- Repositories/data sources with no app-wide state (`BusinessRepositoryImpl`, `ReservationApiService`, `OrderApiService`, etc.) are constructed directly at the call site with `SomeRepositoryImpl(remoteDataSource: SomeRemoteDataSourceImpl())`. Most data sources default to `Supabase.instance.client` when no client is passed, so `SomeRemoteDataSourceImpl()` with no arguments is normally enough.
- If a dependency is genuinely needed in many unrelated places, prefer a small singleton service (see `SessionService` below) over reintroducing a general-purpose locator.

## Backend Access — Supabase Edge Functions Only

**Do not call `Supabase.instance.client.from('table_name')` directly from Flutter code for business data.** All reads/writes for businesses, menu items, rooms, vehicles, reviews, orders, reservations, and the user profile go through **Supabase Edge Functions**, not direct PostgREST `.from()` calls — see `business_remote_datasource_impl.dart`, `review_api_service.dart`, `order_service.dart`, `reservation_service.dart`, and `core/bloc/settings_bloc.dart` for the current pattern. This was a deliberate migration so the app can scale to a large data volume without shipping unbounded/unindexed queries straight from the client, and so joins/enrichment/pagination logic lives server-side once instead of being duplicated per screen.

Supabase project ref: `wrutwzbtnquxigxetxfx`. Do not point Supabase MCP tools at a different project without explicitly confirming with the user — this has happened by mistake before and silently produced analysis of the wrong backend.

### Where Edge Function source lives

Edge Functions are **not** checked into this repository — there is no local `supabase/functions/` folder. They were authored and deployed straight to the remote project via the Supabase MCP tools (`mcp__supabase__deploy_edge_function`, `mcp__supabase__get_edge_function`, `mcp__supabase__list_edge_functions`). To inspect or change a function: fetch its current source with `get_edge_function` first, edit it, then redeploy with `deploy_edge_function` — do not assume a local file exists to edit directly.

Every function shares two helpers deployed alongside it under `_shared/`:

- `_shared/cors.ts` — standard CORS headers.
- `_shared/client.ts` — `createUserClient(req)` builds a Supabase client that forwards the caller's `Authorization` JWT, so RLS policies apply exactly as they would for a direct PostgREST call (guest/anonymous browsing still works, since the anon key itself is a valid JWT). Also exports `paginationParams(url)` for consistent `?page=&pageSize=` parsing.

All functions are deployed with `verify_jwt: true`.

### Naming convention (mandatory for any new Edge Function)

`METHOD-NOUN[-TYPE]` — e.g. `get-home`, `get-business-detail`, `create-review`, `get-orders-client`. The optional `-TYPE` suffix disambiguates *whose* view of the data it is (e.g. `-client` = the calling user's own records, as opposed to a merchant's own published listings). Do not use camelCase, verb-first-without-hyphen, or any other scheme — and do not reintroduce the old pre-migration names (`home-feed`, `business-detail`, `reviews-list`, `orders-list`, `reservations-list`, `submit-review`), which were renamed away from and may still exist as orphaned/unused functions in the dashboard pending manual deletion.

### Current functions

- `get-home` — bundle de l'accueil filtré par catégorie : `{newOffers, popularBusinesses, discoverOffers}`. `?section=new&page=N`, `?section=discover&page=N` et `?section=businesses` renvoient une liste paginée seule (voir « Les trois sections de l'accueil » ci-dessous).
- `get-categories` — catégories de la marketplace, mises en cache par l'app
- `get-business-detail` — `?id=` → `{business, offers, capabilities, menuItems, rooms, vehicles, reviews}`
- `get-offer-detail` — `?id=` → `{offer, business, reviews, otherOffers, remainingCapacity}` : tout ce qu'il faut pour décider devant une offre, sans être passé par la fiche du commerçant
- `get-businesses-budget` — recherche par prix d'entrée réel (`?min=&max=&category=`)
- `get-reviews-business` — `?businessId=&page=`
- `create-review` — `offerId` facultatif : un avis vise une offre précise, ou le commerce
- `get-orders-client` — paginé, noms d'articles figés à la commande
- `get-reservations-client` — paginé, nom du commerçant côté serveur
- `create-order` — n'accepte que des offres et des quantités ; prix et total calculés en base
- `cancel-order-client` — annulation par le client tant que la commande n'est pas préparée
- `update-order-status` — côté commerçant, statut validé contre une liste blanche
- `update-reservation-status` — le commerçant confirme, refuse ou clôt une réservation
- `create-reservation` — vérifie disponibilité, capacité et date ; calcule le montant
- `delete-reservation`
- `get-merchant-space` — tout l'espace commerçant en un appel, **et** la réponse à « cet utilisateur est-il commerçant ? » (`business: null` ⇒ non)
- `create-merchant-application` — dépôt d'une demande de compte commerçant
- `create-offer` / `update-offer` — publication et modification d'une offre par son commerçant
- `get-me` — merges `auth.users` + `public.users`, auto-creates the `public.users` row on first login. **Casing gotcha**: the supabase-js `User` object from `auth.users` uses **snake_case** properties (`user_metadata`, `email_confirmed_at`, `created_at`), not camelCase — a real bug hit and fixed while building this function.

If a screen needs a new kind of server-side data (a new page's initial load, a new mutation), add a new Edge Function following the naming convention above rather than reaching for a direct `.from()` call, even for something that looks like a "simple" query.

### Database performance rules already applied

RLS policies use `(select auth.uid())` rather than a bare `auth.uid()` (avoids per-row re-evaluation), multiple-permissive-policy tables were consolidated into single policies, and every foreign key has a covering index. Keep this pattern in any new policy/migration, and check `mcp__supabase__get_advisors` after schema changes.

## Le moule `offers` — commander, réserver, ou passer en boutique

Tout ce qu'un commerçant publie vit dans **une seule table `offers`** : un plat,
un cosmétique, une chambre, un véhicule, un soin, une séance, un concert, une
prestation. Il n'y a **pas de table par métier**, et il ne doit pas y en avoir.

Le champ structurant est `fulfilment` :

- **`order`** → l'utilisateur *commande* (panier, quantités, `order_items`)
- **`booking`** → l'utilisateur *réserve* (une offre, une quantité, une date)
- **`in_store`** → l'offre est *disponible en boutique* : la plateforme la
  référence et la montre, la transaction se fait sur place. Aucun bouton
  d'achat, et le serveur refuse explicitement de la commander ou de la
  réserver. `capacity` et `starts_at` sont forcés à `null` — une jauge de
  places sur un produit qu'on vient chercher ne veut rien dire.

Autres colonnes utiles : `merchant_id` (qui a publié), `capacity` (places),
`starts_at` (offre datée comme une séance ; vide quand c'est le client qui
choisit sa date), `section` (regroupement interne au catalogue), `metadata`.

**Ce qu'un commerçant permet de faire n'est jamais déduit de son type.** Les
capacités viennent des offres réellement publiées, via `capabilities` renvoyé
par `get-business-detail` (ou la vue `business_capabilities`). Un `switch` sur
`BusinessType` pour décider des actions est un anti-pattern ici : il laissait
sans aucun bouton les catégories non prévues, et en affichait qui ne menaient
nulle part pour celles dont le catalogue n'existait pas.

### Le serveur fait autorité sur l'argent

Le client n'envoie **jamais** de prix ni de total. Il envoie des identifiants
d'offres et des quantités ; `create_order_with_items` et
`create_reservation_for_offer` lisent les prix en base, calculent le montant,
vérifient la capacité restante et refusent une date passée. Toute nouvelle
écriture financière doit suivre cette règle — auparavant le prix venait de la
requête, on pouvait donc commander à n'importe quel montant.

Ces deux fonctions acceptent aussi les identifiants historiques
(`menu_items`, `rooms`, `vehicles`) et retrouvent l'offre correspondante par
`metadata->>'legacy_id'` : c'est ce qui permet aux tunnels menu, hôtel et
location de continuer à fonctionner sans réécriture.

### Piège RLS : la récursion sur `business_staff`

Une policy de `business_staff` qui interroge `business_staff` provoque
`infinite recursion detected in policy`, et **bloque tout ce qui traverse
cette table** — donc commandes et réservations, dont le `RETURNING` déclenche
la policy de lecture. Passer par `private.is_business_staff(...)`, une fonction
`SECURITY DEFINER` hors du schéma exposé par l'API. Ne jamais remettre une
fonction d'aide aux policies dans `public` : PostgREST l'exposerait.

### Découverte sans compte

Le catalogue (`business`, `offers`, `menu_items`, `rooms`, `vehicles`,
`reviews`) doit rester lisible par le rôle `anon`. Une policy réservée à
`authenticated` vide la page de découverte pour un visiteur, ce qui contredit
le principe de navigation libre documenté plus haut.

### Les trois sections de l'accueil

Elles ne montrent délibérément **pas la même chose**. Quand les trois
affichaient des commerçants, une catégorie n'en comptant qu'un faisait lire
trois fois le même nom, et on ne savait pas si une carte était une offre ou
une enseigne.

- **Nouveautés** — les offres publiées depuis moins de `NEW_WINDOW_DAYS`
  (30 jours). Section **entièrement masquée** quand il n'y a rien de récent :
  un titre suivi du vide est pire qu'une absence. Limitée à `NEW_PAGE_SIZE`,
  avec une tuile « Voir plus » en fin de liste s'il en reste.
- **Populaires** — les 3 meilleurs **commerçants**.
- **Découvrir** — les meilleures **offres**, en scroll infini.

Les cartes d'offre (`OfferCardWidget`) et de commerçant sont volontairement
différentes : prix + « chez X » d'un côté, note + catégorie de l'autre.

### Les notes : on note une offre, pas un commerce

`reviews.offer_id` désigne ce qui a été consommé. Le trigger
`refresh_ratings()` recalcule `offers.rating` **et** `business.rating`, cette
dernière étant la **moyenne des notes des offres** du commerce. Aucun client
n'écrit jamais une note directement. Le bouton « Noter » n'apparaît que sur
une commande `delivered` — il n'y a rien à juger d'un plat pas encore goûté.

## L'espace commerçant

Devenir commerçant passe par `submit_merchant_application`, une fonction
`SECURITY DEFINER` : `business` n'a **volontairement aucune policy
d'insertion**, personne ne doit pouvoir créer un commerce arbitraire via
l'API REST. La fonction est le guichet contrôlé — elle valide, crée le
commerce, la fiche `public.users` et la ligne `business_staff` propriétaire.
En l'absence de panneau d'administration, elle accepte à la volée ; les trois
états (`pending`/`approved`/`rejected`) existent déjà pour que la modération
n'impose aucune reprise de l'interface.

**Un commerçant a une application différente.** `MerchantShell` (`/merchant`)
apporte sa propre coquille et sa propre barre de navigation — il ne s'insère
pas dans le `StatefulShellRoute` du client. Au lancement, `MerchantCubit`
répond « commerçant ? » et l'application s'ouvre sur cet espace **une seule
fois** (`consumeLanding()`), après quoi les deux mondes restent accessibles
l'un depuis l'autre. Un commerçant reste un client : il doit pouvoir commander
ailleurs, et son historique ne doit jamais devenir inatteignable.

`MerchantCubit` vit au niveau de l'application : la réponse conditionne à la
fois la navigation et les paramètres. Toute écriture relit l'espace derrière
elle (`_mutate`) plutôt que de recoller un état local — les compteurs du
tableau de bord sont calculés par le serveur, en tenir une seconde version
côté client serait deux vérités pour une même chose.

Le commerce n'est **jamais lu depuis la requête** : `create-offer` le déduit
de la ligne `business_staff` de l'appelant. Retirer une offre la **désactive**
(`is_active = false`) au lieu de la supprimer : elle est référencée par des
commandes passées, et un historique qui perd le nom de ce qui a été acheté ne
vaut plus rien.

Une réservation naît `pending` : le commerçant doit la confirmer. Les textes
côté client disent donc « Demande envoyée », jamais « Réservation confirmée ».

## L'offre est une destination, la fiche commerçant une présentation

Cliquer sur une offre ouvre **sa** fiche (`/offer/:id`), jamais celle du
commerce : l'utilisateur a cliqué sur une chose précise, l'envoyer sur le
catalogue entier le forcerait à la rechercher. C'est sur cette fiche qu'on
commande ou qu'on réserve.

La fiche du commerçant **ne porte plus aucun bouton d'action**. Elle se lit
dans l'ordre des questions qu'on se pose : à propos → son catalogue en
carrousels → contact → horaires → commodités → avis. Le catalogue est la
seule porte vers l'achat, et chaque offre y parle pour elle-même — un bouton
« Commander » générique obligeait à deviner ce qu'on allait trouver derrière.

Les anciens tunnels spécialisés (menu de restaurant, chambres d'hôtel,
flotte de location, panier — `online_order/`, `offer_catalogue_page`,
`business_action*`) **ont été supprimés** : leur unique porte d'entrée était
la section d'actions. Ne pas les recréer ; un besoin propre à un métier
s'exprime dans la fiche d'offre générique (quantité, date, jauge), pas dans
un parcours parallèle réservé à une catégorie.

`remainingCapacity` est calculé par `public.offer_remaining_capacity()`, une
fonction `SECURITY DEFINER` : la RLS de `reservations` ne montre à chacun que
les siennes, donc compter les places prises depuis le client donnait toujours
zéro et affichait une offre presque complète comme entièrement libre. La
fonction ne divulgue qu'un nombre agrégé, jamais qui a réservé.

## Pagination — Infinite Scroll Pattern

Lists that page through server data (currently: the home page's business carousel) use **infinite scroll**, not page-number controls. The pattern, established in `home_page/presentation/bloc/business_bloc.dart` + `home_page/presentation/widgets/business_cards_widget.dart`, must be followed for any new paginated list:

- **All pagination state and logic lives in the Bloc** — `page`, `hasMore`, `isLoadingMore` fields on the loaded state, plus a dedicated `LoadMore...` event that guards against duplicate/concurrent loads (`state is! XLoaded || !state.hasMore || state.isLoadingMore` → no-op).
- **The widget only reports proximity to the end of the loaded list** (e.g. `if (index == items.length - 2) context.read<XBloc>().add(const LoadMoreX());`) — it must not compute page numbers, track `hasMore`, or otherwise know anything about pagination itself. This separation is a hard requirement, not a nice-to-have.
- A failed "load more" call fails silently and resets `isLoadingMore` so the user can simply keep scrolling to retry — don't surface a blocking error dialog/snackbar for a background page fetch.
- The remote data source returns a small record/DTO like `({List<T> items, bool hasMore})`; the domain layer wraps that in a proper named class (e.g. `BusinessesPage`) rather than leaking the raw record above the data layer.

## Loading States — Skeletonizer, Not Spinners

**Il ne reste aucun `CircularProgressIndicator` dans `lib/`**, et il ne doit
pas en réapparaître. Un chargement se montre avec un `Skeletonizer` et des
`Bone` **explicites** qui reprennent la forme de ce qui va s'afficher : un
spinner centré ne dit rien du contenu à venir, et une forme approximative
fait sauter la page au moment du remplacement.

La seule exception est le **bouton en cours d'action** (envoyer, publier,
commander), qui utilise `CustomLoadingButton` — jamais un indicateur brut.

Squelettes partagés, à réutiliser plutôt qu'à redessiner :

- `OffersCarouselSkeleton` (`offers_carousel_section.dart`) — le rail
  d'offres, utilisé par l'accueil, la fiche commerçant et la fiche d'offre.
  Sa hauteur et sa largeur de carte viennent de `OffersCarouselSection`
  (`railHeight()`, `cardWidth`) : les deux ne peuvent pas diverger.
- `OfferCardSkeleton`, `BusinessListRowSkeleton` — les cartes elles-mêmes,
  définies à côté du vrai composant.
- `SearchResultSkeleton`, `FeedListSkeleton`, `BudgetResultsSkeleton`
  (`list_skeletons.dart`) — les listes verticales.
- `HomeSkeleton`, `BusinessDetailSkeleton`, `OfferDetailSkeleton`,
  `MerchantSpaceSkeleton`, `ProfileSkeleton`, `ActivityListSkeleton` — les
  pages entières.

**Quand une page change de structure, son squelette change avec elle.** Il a
déjà dérivé une fois : l'accueil affichait encore le squelette de l'ancien
carrousel promotionnel longtemps après la refonte en triptyque.
`test/home_skeleton_test.dart` épingle désormais cette correspondance.

Le scroll infini suit la même règle : la tuile de fin de liste est un
squelette de l'élément qui arrive, pas un spinner.

## Session / Auth State

The `auth` feature (`lib/features/auth`) only exposes granular per-action Bloc states (`RequestEmailOtpSuccess`, `VerifyEmailOtpSuccess`, `AuthWithGoogleSuccess`, `SignOutSuccess`, etc.) — there is **no** `AuthenticatedState`/`UnauthenticatedState` with a `.user` field anymore.

Anything outside the auth feature that needs to know "is someone logged in" or "what is the current user's id/name/email" must use:

```dart
import 'package:baobabe_0_2/core/services/session_service.dart';

final user = SessionService.instance.currentUser; // AppSessionUser? (id, name, email)
final isLoggedIn = SessionService.instance.isLoggedIn;
SessionService.instance.userChanges; // Stream<AppSessionUser?>
SessionService.instance.authStateChanges; // raw Supabase AuthState stream, used by GoRouter's refreshListenable
```

`SessionService` reads directly from `Supabase.instance.client.auth` — it does not depend on `AuthBloc`. Do not reintroduce `context.read<AuthBloc>().state as AuthenticatedState`-style code outside the auth feature.

`AuthBloc` itself is still the right tool for *performing* auth actions (`RequestEmailOtpEvent`, `VerifyEmailOtpEvent`, `AuthWithGoogleEvent`, `AuthWithAppleEvent`, `SignOutEvent`) — e.g. `context.read<AuthBloc>().add(SignOutEvent())` to sign out from Settings.

### Guest browsing — login is action-gated, not navigation-gated

The app must never force login just to browse. `lib/core/routes/app_router.dart` only redirects to `/login` for routes in `_authRequiredPaths` (currently `/favorites`, `/orders`, `/settings`, `/profil-page`, `/edit-profile` — screens that inherently show or edit the current user's own data). Root `/`, `/home`, `/search`, `/business/:id`, and other browsing routes are reachable without an account.

For actions inside a public screen that need an account (making a reservation, adding to cart/checkout, leaving a review, etc.), gate the action itself — check `SessionService.instance.currentUser`, and if null, prompt sign-in (snackbar + `context.go('/login')`, or similar) at the moment the action is attempted. This pattern is already used throughout `business_detail/presentation/widgets/online_order/`. Do not reintroduce a global "redirect everything to /login when logged out" rule.

## Sensitive Areas

Be careful when editing these areas:

- `lib/features/auth` — the auth flow was recently refactored (OTP + Google + Apple via Supabase). Do not modify these files without an explicit request; other features must adapt to auth via `SessionService`, not the other way around.
- `lib/main.dart` — app bootstrap, bloc wiring, splash screen release.
- `lib/core/routes/app_router.dart` — auth guard/redirects, all top-level routes.
- `lib/core/services/session_service.dart` — single source of truth for session/user identity app-wide.
- `lib/features/business_detail/presentation/widgets/online_order/` — many type-specific reservation modals/pages share the same `BusinessDetailBloc` provided by an ancestor `business_detail_screen.dart`; don't add a second competing provider for it.
- Supabase Edge Functions and migrations (remote, project `wrutwzbtnquxigxetxfx`) — no local source of truth in this repo, only reachable via the Supabase MCP tools; see "Backend Access" above before touching backend data access.

## File Size Rule

**No manual source file under `lib/features` may exceed 300 lines.** When a file grows past that limit, split it into:

- dedicated widget files (one cohesive UI section per file)
- domain entity files (one entity/enum per file when a file mixes several)
- helper/service files (e.g. parsing utilities, enrichment logic separated from the main API service)

This applies to files you create or substantially modify. Do not apply this rule to generated files (`*.g.dart`, generated localizations under `lib/l10n`, or other code-generation output).

When splitting a file, preserve behavior exactly — this is a pure refactor, not an opportunity to change UI or logic unless separately requested.

## Testing And Validation

Mandatory checks after any meaningful code change:

- `flutter analyze lib` (or a targeted subset like `flutter analyze lib/features/<feature>`) — must show no new **errors**. Pre-existing warnings/info-level lints (e.g. deprecated `withOpacity`, `avoid_print`) are known debt and not blocking, but don't add new ones gratuitously.
- `flutter pub get` after any `pubspec.yaml` change.
- If the change touches a runtime flow (auth, booking, cart, orders), verify it end to end when a device/emulator is available; state clearly if it wasn't possible to test on-device.

## Working Rules For Future Agents

1. Do not reintroduce `get_it`, `GetIt`, or any service-locator/injector file. Construct dependencies directly (see "Dependency Wiring" above).
2. Do not access auth session/user data outside `lib/features/auth` through `AuthBloc` state casting — use `SessionService.instance`.
3. Do not modify files under `lib/features/auth` unless explicitly asked; adapt consumers instead.
4. Keep every manual file under `lib/features` at or under 300 lines; split proactively rather than letting a screen/widget grow.
5. Respect the BLoC/Cubit architecture — keep business logic out of widgets when practical.
6. Preserve the existing UI language (`AppColors`, `AppDimens`, `AppFonts`) — a full design-system rewrite is tracked separately and has not started yet; do not redesign screens incidentally while doing unrelated work.
7. Run `flutter analyze` on the files/features you touched before considering a task complete, and fix any errors you introduced.
8. When in doubt about scope (e.g. whether a fix belongs in `add_fund`-style adjacent features), ask rather than guessing — this project has several overlapping booking/order flows (`booking_page`, `order`, `business_detail/online_order`) that must stay distinct.
9. **Never recreate a component, color, or spacing value that already exists.** Before writing a button, bottom sheet, loading indicator, card, spacing value, color, or font style, check:
   - `lib/core/widgets/` (e.g. `button/custom_button.dart`, `button/custom_auth_icon_button.dart`, `button/outlined_button_with_icon.dart`, `custom_bottom_sheet.dart`, `custom_loading.dart`) for existing shared widgets.
   - `lib/core/themes/app_colors.dart` (`AppColors`) for every color — never hardcode a `Color(0x...)`/`Colors.xxx` literal when an equivalent `AppColors` constant exists.
   - `lib/core/themes/app_diemens.dart` (`AppDimens`) for every spacing/padding/radius/size value — never hardcode a raw number when an equivalent `AppDimens` constant exists.
   - `lib/core/themes/app_fonts.dart` (`AppFonts`) for font family/weight/size — never hardcode `TextStyle` values that duplicate an existing `AppFonts` constant.
   - The relevant feature's own `presentation/widgets/` folder for a feature-local widget that already does the same job (e.g. reservation cards, filter chips, empty states already extracted during the 300-line cleanup).
   - **Always import and reuse the existing component/constant instead of duplicating it.** Only create a new shared widget/constant when nothing existing covers the need, and prefer adding it to `lib/core/widgets` or the theme files so it becomes reusable rather than duplicating it inline in a feature file.
10. Never call `.from('table_name')` directly from Flutter for business data — go through a Supabase Edge Function following the `METHOD-NOUN[-TYPE]` naming convention (see "Backend Access — Supabase Edge Functions Only" above).
11. Any new paginated list must use the infinite-scroll pattern with all pagination state/logic kept in the Bloc — never in the widget (see "Pagination — Infinite Scroll Pattern" above).
12. **Aucun `CircularProgressIndicator` dans `lib/`.** Tout chargement de
    contenu passe par `Skeletonizer` + des `Bone` explicites reprenant la
    forme réelle ; un bouton en action utilise `CustomLoadingButton`. Un
    squelette doit être mis à jour en même temps que la page qu'il reflète
    (voir « Loading States — Skeletonizer, Not Spinners » ci-dessus).
14. Toute offre publiée passe par la table `offers` et son `fulfilment`
    (`order` / `booking`) — jamais une table par métier, jamais un `switch` sur
    `BusinessType` pour décider des actions possibles (voir « Le moule
    `offers` » ci-dessus).
15. Le client n'envoie jamais un prix ni un total : le serveur les calcule
    depuis le catalogue. Toute nouvelle écriture financière doit suivre cette
    règle.
16. Le cache local passe par `LocalCache` (Hive), jamais `sqflite` : celui-ci
    n'existe pas sur le web, et comme le cache s'écrit à l'intérieur du `try`
    réseau, son échec s'y confondait avec une panne et faisait échouer l'écran.
17. Une note se pose sur une **offre**. La note d'un commerce est dérivée, pas
    saisie : ne jamais écrire dans `business.rating` ni `offers.rating` depuis
    l'application (voir « Les notes » ci-dessus).
18. Le commerce d'un commerçant se déduit **toujours** côté serveur de sa ligne
    `business_staff` ; ne jamais accepter un `businessId` venu de la requête
    pour une écriture (voir « L'espace commerçant » ci-dessus).
19. Une offre se retire (`is_active = false`), elle ne se supprime pas : les
    commandes et réservations passées la référencent.
21. Un clic sur une offre ouvre `/offer/:id` ; un clic sur un commerçant
    ouvre `/business/:id`. Ne jamais renvoyer l'un vers l'autre.
22. Le troisième `fulfilment`, `in_store`, n'ouvre aucune transaction dans
    l'application. Tout code qui suppose « commande ou réservation » (badge,
    bouton, message d'erreur, statistique) doit traiter ce cas explicitement
    plutôt que de le ranger dans le `else`.
20. Une policy d'UPDATE réservée au client doit borner ce qu'il peut écrire.
    « Le client peut annuler sa commande » autorisait en réalité *n'importe
    quelle* mise à jour de sa commande, y compris se déclarer livré ;
    l'annulation passe désormais par `cancel_order()` seule. Vérifier le
    `WITH CHECK` de toute nouvelle policy d'écriture.
13. **`lib/core/themes/app_theme.dart` (`AppTheme.silvaTheme`) is the single source of truth for the app's `ThemeData`.** The app currently ships one theme only (light — `brightness: Brightness.light`, no `darkTheme` wired into `MaterialApp.router`). When a task calls for visual/theming work:
    - Never invent a one-off color palette or a screen-specific "look" (e.g. a dark card style copied from a design mockup) that doesn't route through `AppColors`/`AppTheme`. If a design reference (mockup, screenshot) implies colors that don't exist in `AppColors`, restyle the layout using the existing palette instead of introducing new literals — ask the user first if the existing palette genuinely cannot express the design.
    - If a real second theme (e.g. an actual dark mode) is ever needed, it must be added properly: new tokens in `AppColors`, a second `ThemeData` in `AppTheme`, and `darkTheme`/`themeMode` wired into `MaterialApp.router` in `lib/app/main_app.dart` — not a scoped-to-one-screen imitation. Don't half-build this (e.g. a theme picker UI that stores a `ThemeMode` nobody consumes) — a `SettingsCubit.themeMode` + theme-picker dialog like this existed and was removed for being fully decorative; don't reintroduce that pattern.

## Le thème est la source unique de la couleur et de la typographie

**Aucun écran ne nomme une couleur ni une police.** Tout passe par
`Theme.of(context)`. C'est ce qui rend un thème sombre possible sans toucher
un seul widget : il se fabriquerait entièrement dans
`lib/core/themes/app_theme.dart`, en composant un second `ColorScheme` et un
second `OtherTheme` puis en les passant à `_build`.

| besoin | où le lire |
|---|---|
| vert de marque, fonds, texte, erreur | `Theme.of(context).colorScheme` |
| succès, attention, note, catégories | `OtherTheme.of(context)` |
| tailles et graisses | `Theme.of(context).textTheme` |
| espacements, rayons | `AppDimens` (sans rapport avec le thème) |

`AppColors` et `AppFonts` ne sont plus que les **valeurs primitives** lues par
`app_theme.dart`. Les lire depuis un écran contourne le thème.
`test/theme_centralisation_test.dart` échoue alors en désignant le fichier et
la ligne — il refuse aussi `Color(0x…)`, `Colors.xxx` et tout `fontSize:` hors
du thème.

Ce que cela implique en pratique :

- **Une valeur par défaut de paramètre ne peut pas lire le thème.** Le
  paramètre devient `Color?` et `build` tranche : `color ?? scheme.primary`.
- **Un getter de modèle non plus.** `OrderStatus.color`, `UIBusiness.categoryColor`
  et `Reservation.typeColor` sont devenus des méthodes prenant un
  `BuildContext`.
- **`const` disparaît** des widgets qui lisent le thème. C'est le prix normal
  de la centralisation, pas une régression à corriger.

### Deux rôles par teinte sémantique

Une couleur d'état sert à deux choses qui n'ont pas les mêmes exigences :
**remplir une surface** et **porter du texte**. Chaque famille suit donc la
grammaire de Material : `xxx` (l'aplat), `onXxx` (ce qui se pose dessus),
`xxxContainer` (la pastille), `onXxxContainer` (son texte).

Les valeurs `...Content` de `AppColors` ont été calculées pour satisfaire
**trois** contraintes à la fois : ≥ 4,5:1 en texte sur blanc, ≥ 4,5:1 sous du
blanc, et ≥ 4,5:1 sur leur propre surface. Ne pas les retoucher à l'œil.

- **`secondaryLight` n'est jamais une couleur de texte, et rien de blanc ne se
  pose dessus** (1,83:1). Elle ne vit plus que comme `outlineVariant`.
- **Une pastille reçoit une surface explicite, jamais un `withValues(alpha:)`
  de sa propre couleur** : le contraste dépendrait de ce qu'il y a derrière,
  donc invérifiable — et il tombait à 3,8:1.

La note a un rôle unique, `OtherTheme.rating`, au lieu de quatre nuances
d'ambre selon le fichier. L'étoile reste vive parce qu'un chiffre l'accompagne
toujours ; dès qu'un **texte** exprime la note, c'est `onRatingContainer`.

Le cycle de vie d'une commande (`OrderStatus.color(context)` / `.surface(context)`)
n'encode pas six catégories mais **qui tient la balle** : ambre en attente,
vert de la marque pendant le traitement, vert de réussite quand c'est prêt,
neutre une fois terminé, rouge si c'est arrêté.

### L'échelle typographique

Les quinze cases du `TextTheme` sont remplies et couvrent chaque taille
employée dans l'application. Un écran n'a plus aucune raison d'écrire un
`TextStyle` : il prend la case et surcharge la couleur si besoin.

L'échelle compte treize marches distinctes (12 à 28 px) — le signe d'une
échelle accumulée plutôt que dessinée. La resserrer relève d'une passe
`/impeccable typeset`, pas d'une retouche au fil de l'eau.

## Réseau et images : le contexte commande

PRODUCT.md pose un réseau irrégulier et des téléphones modestes. Deux règles
en découlent, et elles ont chacune été enfreintes une fois :

- **Une page = un appel.** L'écran d'un commerçant et sa section catalogue
  interrogeaient chacun `get-business-detail` pour la même réponse : 1,5 s et
  20 Ko au lieu de 0,7 s et 10 Ko, à chaque ouverture. Le fetch vit dans
  `OfferApiService.getPage()`, le bloc distribue. Une section qui a besoin de
  données va les chercher **auprès de son bloc**, jamais auprès du serveur.
- **Aucune image distante en direct.** Toutes passent par
  `core/widgets/remote_image.dart` (`RemoteImage` / `RemoteThumbnail`), qui
  met en cache sur le disque, montre un squelette pendant l'attente et un
  repli propre à l'échec. `Image.network` ne garde rien : chaque retour sur
  l'accueil relançait les téléchargements.

Beaucoup d'URL en base sont des liens de **page** plutôt que de fichier image
(`https://www.pexels.com/fr-fr/photo/...`). Le repli n'est donc pas un cas
rare : il fait partie du rendu normal.

## Du téléphone au bureau : une colonne, pas un tableau de bord

PRODUCT.md engage l'application sur trois cibles depuis un seul code, avec
**un seul langage visuel**. Adapter au bureau ne veut donc pas dire inventer
des colonnes : cela veut dire donner à l'application sa largeur naturelle et
laisser le reste de la fenêtre tranquille.

`core/widgets/adaptive_viewport.dart` s'en charge **une fois**, dans le
`builder` de `MaterialApp` : toutes les routes en héritent, espace commerçant
compris. Au-delà de 560 px, le contenu tient dans une colonne centrée bordée
d'un filet.

Le point à ne pas manquer : **le `MediaQuery` est réécrit** pour la
sous-arborescence. Tout ce qui mesure la largeur voit celle de la colonne, pas
celle de la fenêtre — sinon l'application se croit sur un écran large tout en
n'occupant qu'une bande. Ne pas ajouter d'autre règle de largeur ailleurs :
`ResponsiveContainer` en portait une seconde, appliquée par une seule page.

### Une hauteur figée finit toujours par tronquer

Le bloc d'accueil réservait 58 px en dur, donc la question tenait sur une
ligne — coupée par une ellipse dès 375 px, et partout une fois traduite en
lingala. `HomeSliverHeaderMetrics.greetingHeight(context)` **mesure** le texte
réel, à la largeur réelle et à l'échelle de police du système ; l'en-tête
réserve ce qu'il faut, et la course d'aimantation suit.

Règle générale : dès qu'un texte traduisible vit dans une boîte de hauteur
constante, la boîte doit mesurer son contenu. Le produit tient trois langues.

### Cibles tactiles

`AppDimens.touchTarget` vaut 48 dp, le minimum Material. `VisualDensity.compact`
et `constraints: BoxConstraints()` sur un `IconButton` descendent en dessous —
ils ne s'emploient pas sur un contrôle qu'on vise du doigt.

`test/adaptive_layout_test.dart` épingle les trois règles : la colonne, le
non-débordement de l'en-tête de 320 px à 1400 px et à 160 % de police, et le
jeton tactile.

## Résilience : ce que le réel envoie

`test/hardening_test.dart` épingle quatre règles, chacune née d'un défaut
réel trouvé dans ce code.

- **Les données de locale se chargent au démarrage.** `intl` ne connaît que
  sa locale par défaut : sans `initializeDateFormatting('fr_FR')` dans
  `main()`, tout `DateFormat` en français **lève**. Trois écrans en
  formataient — la fiche d'une offre datée et la boîte de réception du
  commerçant plantaient au premier affichage.
- **Une locale que Flutter ne sait pas rendre retombe sur le français.**
  `ln_CD` n'existe pas dans ses locales : un téléphone réglé sur le lingala
  affichait une interface française avec un sélecteur de date anglais. Le
  `localeResolutionCallback` de `main_app.dart` tranche.
- **Aucune exception brute ne se montre.** `Text('Erreur: $e')` affichait une
  trace de pile à quelqu'un qui voulait lire un avis. L'erreur part au
  journal ; l'utilisateur lit une phrase qui nomme ce qui a échoué.
- **Aucun bouton ne mène nulle part.** `onPressed: () {}` est un contrôle
  décoratif. Quatre en portaient un — le cœur « favori » de la fiche
  commerçant et trois entrées de paramètres. Ils ont été retirés, pas
  câblés à vide : ils reviendront avec ce qu'ils promettent.

Deux règles qui en découlent et que le test ne peut pas voir :

- **Une action en vol ferme son bouton.** `MerchantReady.isWorking` existait
  mais n'était lu nulle part : deux tapes rapides envoyaient deux changements
  de statut.
- **Trois langues, donc aucune largeur figée autour d'un libellé.** Le test
  refuse `SizedBox(width: …, child: Text(…))`.

**Les traductions n'existent pas.** `supportedLocales` annonce trois langues,
mais chaque chaîne est écrite en français dans le code : il n'y a ni fichier
ARB ni délégué applicatif. Livrer l'anglais et le lingala demande une passe
d'internationalisation complète — c'est du contenu, pas de la technique.

## Le vocabulaire de l'interface

PRODUCT.md fixe un glossaire : **offre**, **commerçant**, **commerce**,
**activités**. Deux mots pour une même chose obligent l'utilisateur à deviner
s'il s'agit de la même chose — « établissement » et « commerce » cohabitaient
sur sept écrans.

`test/copy_test.dart` tient quatre règles, chacune née d'un défaut réel :

- **« commerce », jamais « établissement ».**
- **Aucun texte n'avoue une fonctionnalité manquante.** « Profil mis à jour
  (à implémenter) » confirmait un enregistrement qui n'avait pas eu lieu, et
  refermait la page. Une confirmation ne confirme que ce qui s'est produit.
- **Aucun texte d'interface en anglais.** Les erreurs de connexion Google
  l'étaient toutes, et l'une citait **« Bicount »** — le nom d'un autre
  produit — sur un écran français, dans un SnackBar.
- **Aucun ternaire de pluriel dont les deux branches sont identiques.**

### Les trois sections de l'accueil nomment leur contenu

Deux montrent des **offres**, une montre des **commerces**. Les libellés le
disent : « Nouveautés », « Commerces populaires », « Offres les mieux
notées ». Un titre en verbe (« Découvrir ») au milieu de titres en nom
rompait le parallélisme, et « nos meilleurs offres » était fautif.

### Ce qu'un état vide doit dire

Nommer l'état, puis l'action suivante. « Rien à afficher pour le moment » ne
distingue pas la première visite d'un filtre trop étroit ni d'une panne.

### Pas de saut de ligne forcé dans un libellé

`
` au milieu d'une phrase casse à la traduction et à l'agrandissement de
police. Le texte s'écoule ; `textAlign` fait le reste.

## UI And Design System

A dedicated design system pass (colors, typography, spacing, component consistency) is planned but has **not started**. Until a `ui-design-systems` reference file exists in this repo, do not perform a broad visual redesign — only make the minimal visual changes required by the task at hand, using the existing `AppColors`/`AppDimens`/`AppFonts` constants under `lib/core/themes`, and never colors/styles outside of what `AppTheme.silvaTheme` (`lib/core/themes/app_theme.dart`) already defines or composes from those constants (see rule 13 above).

## Un écran fini rend ce qu'il a récupéré

Trois défauts trouvés dans la même passe, tous de la même famille : la donnée
est demandée au serveur, elle arrive, et personne ne la montre.

- « Trouver selon mon budget » calculait un prix moyen par commerce et
  décidait s'il tenait dans le budget, puis affichait des rectangles vides —
  la liste s'appuyait sur un `BusinessCardPlaceholder` resté à l'état
  d'ébauche, avec son `TODO` intact.
- L'icône de filtre de la page de recherche était un `CustomCard` **sans**
  `GestureDetector` : rien ne se passait au doigt. Elle est raccordée à la
  même destination que sa jumelle de l'accueil.
- `SearchFilterSheet` — 394 lignes de panneau de filtres — n'était ouvert par
  rien. Supprimé : il s'appuyait sur l'énumération `BusinessType` figée, que
  les catégories venues du serveur ont remplacée. Un panneau de filtres se
  rebâtira sur les slugs du serveur, pas sur cette liste codée en dur.

Les règles qui en découlent :

1. Un widget nommé `*Placeholder` ne survit pas à la revue. S'il rend une
   boîte vide, il masque un écran non terminé derrière une apparence de
   travail fait.
2. Un contrôle visible se teste au doigt, pas à l'œil. Un `Container` décoré
   qui ressemble à un bouton et n'a pas de `onTap` est un mensonge.
3. Une valeur portée par une entité (`averagePrice`, `matchesBudget`) et
   jamais lue par un widget est soit un écran inachevé, soit un champ mort.
   Les deux se corrigent, aucun ne se garde.

`test/budget_results_test.dart` tient la première ; `test/hardening_test.dart`
(« aucun bouton ne mène nulle part ») tient la deuxième.

## Le message d'erreur n'est pas le journal

`emit(FeedError('Impossible de charger le feed : $e'))` mettait sous les yeux
de quelqu'un qui ouvrait l'accueil le texte
« Erreur Edge Function (get-home) lors du chargement… ». L'exception est pour
`debugPrint`, la phrase écrite est pour l'écran :

```dart
} catch (e) {
  debugPrint("Chargement de l'accueil — échec : $e");
  emit(
    const FeedError(
      "L'accueil n'a pas pu être chargé. Vérifiez votre connexion et réessayez.",
    ),
  );
}
```

Le piège est que l'exception se colle au message **bien avant** l'affichage —
dans un état de bloc, un `errorMessage` de cubit — donc surveiller le
`Text(...)` final ne suffit pas. `test/hardening_test.dart` inspecte toute
phrase d'interface qui interpole `$e`, en exemptant `throw`, `debugPrint` et
le journal.

## Une seule fenêtre pour « êtes-vous sûr ? »

`lib/core/widgets/custom_pop_up.dart` est le modèle unique de la confirmation.
Aucun écran ne construit son propre `AlertDialog` — `test/custom_pop_up_test.dart`
le vérifie, avec une seule exception nommée dans le test : le sélecteur de
langue, qui est un choix entre options et non une confirmation.

```dart
final confirme = await showCustomPopUp(
  context: context,
  title: 'Voulez-vous vraiment annuler votre réservation ?',
  message: 'Votre réservation chez Chez Nadine sera supprimée. '
      'Vous pourrez réserver à nouveau quand vous voulez.',
);
if (!confirme) return;
```

Ce que le modèle règle une fois pour toutes :

1. **La réponse est un `bool`, jamais un `bool?`.** `showDialog` rend `null`
   quand on sort sans choisir. Ce `null` se lit « faux » dans un `if`, mais
   « vrai » dans un `!= false` — soit une suppression que personne n'a
   demandée. `showCustomPopUp` tranche à la sortie : seul le bouton d'action
   rend `true`.
2. **L'intention se nomme, la couleur se déduit.** `PopUpIntent.destructive`
   prend `colorScheme.error`, `PopUpIntent.neutral` prend `primary`. Aucun
   écran ne choisit un rouge.
3. **La question est dans le titre, pas sur les boutons.** Le titre demande
   « Voulez-vous vraiment annuler votre commande ? », le message dit la
   conséquence et ce qui reste possible ensuite, et les boutons se contentent
   de **Retour** et **Confirmer**.

   La première version nommait l'action sur le bouton (« Annuler la
   commande »). Deux défauts en un : ce bouton se retrouvait face à un bouton
   « Annuler » qui voulait dire l'inverse, et il était assez long pour que
   l'`OverflowBar` d'`AlertDialog` empile les deux l'un sous l'autre. Les
   actions sont donc composées à la main dans un `Row` à parts égales — une
   seule ligne, quelle que soit la longueur des libellés.

   « Retour » plutôt qu'« Annuler » comme libellé de renoncement : quand
   l'action confirmée *est* une annulation, « Annuler » ne veut plus rien
   dire.
4. **La fenêtre demande, elle n'agit pas.** L'ancienne boîte de déconnexion
   déclenchait `SignOutEvent` depuis son propre bouton, sans même se refermer.
   Elle rend maintenant une réponse ; l'appelant décide.

5. **Le message défile.** La zone de contenu d'`AlertDialog` ne le fait pas
   d'elle-même : un message long, ou un fort agrandissement du texte, en
   coupait la fin sans rien laisser paraître — et c'est précisément la
   conséquence de l'action qu'il ne faut pas tronquer.

Les deux gabarits d'avant — bouton texte rouge dans l'activité, bouton plein
rouge à la déconnexion — sont unifiés sur le bouton plein : c'est l'affordance
la plus claire pour une action qui ne se reprend pas, et elle existait déjà
dans l'application.

**La suite ne compare plus d'images.** Elle l'a fait — `test/goldens/` —, et
c'était un mauvais marché : une capture dit « ça a changé » sans dire quoi,
elle diffère d'une machine à l'autre selon le rendu des polices, et il faut
la régénérer à chaque retouche légitime. Ce qu'elles gardaient est désormais
tenu par des **mesures** : `profile_skeleton_test.dart` compare la largeur du
squelette à celle du contenu, `animation_test.dart` compare les positions
avant et après une entrée. N'en réintroduisez pas.

### L'écran d'activité : un flux, pas deux onglets

Refonte à partir d'une maquette Claude Design (« Écran réservations et
commandes »). Ce qui change, et pourquoi :

- **un seul flux chronologique** au lieu de « Commandes » / « Réservations ».
  Deux onglets obligent à savoir, avant de chercher, dans lequel ranger ce
  qu'on cherche. Or on ne se souvient pas d'une catégorie : on se souvient
  d'un commerce et d'un moment. La nature est devenue une mention dans la
  ligne ;
- des **lignes** et non des cartes. Six cartes ombrées font six boîtes à lire
  séparément ; un filet vertical marque ce qui est en cours, un filet
  horizontal sépare, l'œil descend sans obstacle ;
- **ce qui est en cours d'abord**, l'historique ensuite. Le flux était
  purement chronologique, et une commande de la semaine dernière que le
  commerçant n'a pas honorée se retrouvait enterrée sous les repas d'hier —
  or c'est exactement la ligne qu'on vient voir. `ActivityGroup.from` sort
  donc les entrées `!isSettled` sous un repère « En cours », en tête, quelle
  que soit leur date ; le reste garde « Hier », « Cette semaine ». Une ligne
  annulée est réglée : elle n'attend rien, elle appartient à l'historique ;
- toucher une ligne ouvre son reçu en **page entière** (`/activity`,
  `ActivityDetailPage`, hors du shell). Il s'ouvrait d'abord dans l'onglet,
  et la barre de navigation restait donc sous un reçu : elle proposait
  d'aller ailleurs au moment précis où l'on montre un code au comptoir, et
  le dernier bouton du reçu finissait dessous. La page rend `true` quand elle
  a changé quelque chose — annulation, note — et c'est la seule chose qui
  déclenche un rechargement du flux : revenir d'un reçu qu'on a seulement lu
  ne coûte rien. Elle remplace `/order-detail` et `/reservation-detail`, qui
  séparaient ce que le flux a réuni ;
- l'action du reçu prend **toute la largeur**, et l'annulation est *tracée*
  (`ActionButtonTone.dangerOutline`) : au pied d'une page entière un bouton
  court flotte sans appui, mais un aplat rouge pleine largeur crierait plus
  fort que ce qu'il propose — la confirmation qui suit porte déjà le poids du
  geste.

`ActivityEntry` est le seul endroit qui traduit un `Order` ou une
`Reservation` en ce que la ligne affiche ; aucun widget ne connaît les deux.

Deux règles d'affichage tirées de l'usage, pas de la maquette :

- **la note ou la jauge, jamais les deux.** À elles deux elles ne tiennent
  pas sur la ligne, et le libellé se faisait tronquer en « En attente — Le
  comm… ». Une attente se dit en mots, une progression se montre ;
- **cet onglet n'a pas d'app bar** : l'en-tête et la barre du reçu réservent
  eux-mêmes `MediaQuery.paddingOf(context).top`. Le flux réserve en bas la
  hauteur de la barre de navigation, qui flotte au-dessus du contenu ; le
  reçu, qui est une page, ne réserve que `viewPadding.bottom` — la barre de
  gestes du système, imposée par le bord à bord (cible API 35) ;
- **un squelette remplit l'écran.** Quatre lignes en haut d'une page vide
  laissaient un grand blanc en dessous, qui se remplissait d'un coup à
  l'arrivée des données. `ActivityFlowSkeleton` déduit son nombre de lignes
  de la hauteur disponible et dépasse d'une : un flux qui s'arrête pile au
  bas de l'écran a l'air fini, alors qu'il charge.

Une rangée en `CrossAxisAlignment.stretch` dans une liste défilante lève
« BoxConstraints forces an infinite height » : le filet de gauche passe donc
par `IntrinsicHeight`.

**Ce que la maquette prévoyait et que les données ne permettent pas** : le
bouton « Appeler ». `Order.customerPhone` et `Reservation.phoneNumber` sont
ceux du *client* — le composer reviendrait à s'appeler soi-même. Le téléphone
du commerce vit sur `business.phone`, qu'aucune des deux entités ne rapatrie.

Le **code du reçu** est dérivé de l'identifiant, donc stable, et le QR encode
`baobabe:order:<id>`. Rien ne le vérifie côté serveur : c'est une référence
lisible, pas une preuve.

### Valider n'est pas lire

`CheckoutCubit` (`features/order/presentation/cubit/`) porte la commande et la
réservation. C'était dans `OfferDetailCubit`, mêlé à la lecture de la fiche,
avec deux conséquences visibles :

- une validation réussie appelait `load()`, qui repasse par
  `OfferDetailLoading` : **toute la page redevenait un squelette** alors que
  l'utilisateur venait d'appuyer sur un bouton — et un squelette veut dire
  « ça charge », soit l'inverse de ce qui venait de se produire ;
- « en train de valider » était un champ de l'état de la fiche, donc chaque
  frappe sur la quantité le traversait.

Après la séparation : `OfferDetailCubit.refresh()` relit **sans** repasser par
le squelette, et la réussite se dit par `showCheckoutSuccessSheet` — la même
coche tracée que la fin de la connexion par code, qui se referme d'elle-même.

Le cubit prend sa session en paramètre (`session:`) : un cubit qui lit un
singleton global ne se teste pas, et c'était le cas avant.

### Un écran qui lit la session doit l'écouter

`AuthSessionCubit` est fourni pour toute l'application depuis `main_app`. Un
écran qui écrit `SessionService.instance.currentUser` dans son `build` lit un
instantané : se connecter ne le met pas à jour, et rien ne le montre tant
qu'un autre événement ne provoque pas de reconstruction. C'était le cas des
réglages, et de la salutation de l'accueil.

La règle : lire la session **dans** un `BlocBuilder<AuthSessionCubit, …>`, ou
à défaut la relire à chaque `build` avec un flux qui déclenche la
reconstruction. Sous test, un bloc livre son état sur une micro-tâche : il
faut deux `pump()` pour voir le changement.

### Tirer pour rafraîchir : partout, et par le même composant

`core/widgets/custom_refresh.dart`. Cinq écrans avaient un `RefreshIndicator`
écrit à la main, les dix autres n'avaient rien — or c'est le seul recours
quand une donnée est en retard, et une application où le geste marche sur une
page et pas sur la suivante apprend à ne pas l'essayer.

`awaitSettled` accompagne : la roue tourne jusqu'à ce que le futur s'achève,
or la plupart des rechargements passent par un événement de bloc, qui ne rend
rien. Elle attend l'état d'arrivée — chargé **ou en erreur**, une erreur étant
une fin — avec un délai de garde pour que la roue s'arrête même si le bloc
n'émet jamais.

Restent sans geste, faute d'avoir quoi que ce soit à recharger :
`notification_screen` (une ébauche), `order_detail_page` et
`boking_detail_screen` (des vues construites sur des données reçues).

### L'adresse d'un commerce, en colonnes

`business` et `merchant_applications` ont les six paliers de `user_info` :
province, ville, commune, quartier, avenue, numéro. Ils tenaient sur une
colonne de texte libre, ce qui interdit tout regroupement — on ne peut pas
lister les commerces d'une commune sans deviner ce que contient la chaîne.

`address` reste, et devient un **rendu** composé à l'écriture par
`public.address_one_line`, miroir exact de `UserAddress.oneLine`. Ce n'est pas
un oubli de normalisation : une dizaine de lectures l'affichent déjà, et leur
faire recomposer la ligne multiplierait les façons de l'écrire.

Le formulaire vit dans une feuille, réutilise `AddressForm` — celui de la
livraison — et range son explication derrière un bouton d'information : elle
rassure la première fois et encombre les suivantes.

### Notifications : la permission ne se demande pas n'importe quand

La demande **ne suit pas la connexion**. À cet instant elle n'a aucune
justification, et une demande sans raison se refuse — une fois pour toutes,
puisque Android ne remontre plus sa boîte après deux refus. Elle suit une
**action accomplie** qui appelle une suite : une commande passée, une
réservation posée, un commerce créé. Chacune porte sa raison propre
(`NotificationReason`), et la feuille l'expose avant de passer la main.

Notre feuille n'accorde rien : c'est un pré-consentement. Le bouton déclenche
la boîte du système, seule à autoriser.

La règle vit **entière** dans `NotificationPreferences`, qui ne touche ni à
Firebase ni à un widget et se teste donc sans émulateur :

- accepté une fois → plus jamais demandé, pour aucune action ;
- refusé → on n'insiste pas sur le même prétexte ;
- une action d'une autre nature peut reposer la question, une fois ;
- au-delà de deux refus → plus jamais. Il reste le réglage des paramètres,
  qui remet le compteur à zéro : quelqu'un qui active lui-même revient sur
  son refus.

### Le jeton d'appareil : trois mouvements, pas un

Un jeton ne se pose pas une fois pour toutes, et deux des trois mouvements
sont invisibles depuis l'application :

1. on l'obtient à l'accord ;
2. **Firebase le remplace de lui-même**, sans rien demander — d'où l'écoute
   de `onTokenRefresh` ; sans elle les notifications s'arrêtent un jour, en
   silence ;
3. **le compte change** : téléphone neuf, prêté, revendu, ou simple
   déconnexion.

Le troisième est tenu en base : `device_tokens.token` est **unique**, et non
la paire (utilisateur, jeton). Se connecter sur un appareil déjà connu le
rattache au nouveau compte et détache l'ancien. Sans cela, revendre son
téléphone laisserait fuiter ses notifications.

C'est aussi pourquoi les écritures passent par `register-push-token` avec le
rôle de service : rattacher suppose de toucher la ligne d'un *autre*
utilisateur, ce qu'aucune politique RLS honnête ne peut autoriser. L'identité
vient du JWT vérifié, jamais du corps de la requête. Le client, lui, n'a que
`SELECT` sur ses propres lignes.

`unregister-push-token` est appelé **avant** `signOut()` (crochet
`SessionHooks`) : après, il n'y a plus d'identité à présenter et la ligne
resterait — la personne suivante à se connecter recevrait les notifications
de la précédente.

Le jeton est enregistré **dès la connexion, même sans permission accordée** :
sur Android le jeton identifie l'appareil, la permission ne gouverne que
l'affichage. L'accord devient donc effectif sans aller-retour.

### L'envoi : une seule fonction parle à Firebase

`send-push`, et elle seule. Les autres passent par `_shared/notify.ts`, qui
fait un appel interne authentifié par la clé de service — laquelle est un JWT,
donc `verify_jwt` reste actif et la fonction n'est pas une porte ouverte ;
elle vérifie en plus que le rôle du porteur est `service_role`.

Sans cette centralisation, les trois cents lignes de signature OAuth2 (l'API
à « clé serveur » a été retirée en 2024 ; la v1 exige un JWT RS256 signé avec
la clé d'un compte de service) seraient recopiées dans les six fonctions qui
notifient.

**Un envoi ne fait jamais échouer l'action qui le déclenche.** C'est la raison
des `catch` vides autour des appels de notification — les seuls du dossier.

**À poser une fois** : le secret `FCM_SERVICE_ACCOUNT` sur le projet Supabase
(le JSON de la clé du compte de service, tel quel). Sans lui tout fonctionne,
mais rien ne part : `send-push` répond `no_service_account` au lieu d'échouer.

### Bord à bord : déjà en vigueur, pas à préparer

Flutter fixe `targetSdk` à 36. Le bord à bord est imposé dès la cible 35 :
l'application y est soumise **aujourd'hui**. En conséquence,
`windowDrawsSystemBarBackgrounds`, `statusBarColor` et `navigationBarColor`
n'ont plus aucun effet — ils ont été retirés des quatre `styles.xml`.

Ce qui les remplace :

- `AppTheme.systemOverlay` fixe la teinte des icônes système ;
- la barre de navigation basse ajoute `viewPadding.bottom` à sa marge — elle
  valait 16 en dur, et la barre de geste se posait par-dessus les onglets ;
- la feuille modale borne sa hauteur par le haut **et** par le bas.

Les encarts de la feuille se lisent sur `View.of(context)` et non sur le
`MediaQuery` : celui-ci est consommé en chemin — `showModalBottomSheet` retire
l'encart du haut de celui qu'il passe à son contenu, si bien qu'une feuille
ouverte depuis une autre feuille trouvait zéro et remontait sous l'heure.

Pour comparer avant/après sans recompiler :
`adb shell am compat disable OVERRIDE_ENABLE_EDGE_TO_EDGE com.app.baobab02`.

### Déconnexion : deux pièges enchaînés

Elle en demandait deux pour une, et il y avait deux causes :

1. `add(SignOutEvent())` ne fait qu'**empiler** l'événement. La navigation qui
   suivait partait alors que la session était encore ouverte, et la garde du
   routeur — « connecté sur une route d'authentification ? alors `/home` » —
   la renvoyait à l'accueil. On attend désormais `SignOutSuccess` ou
   `SignOutFailure` avant de bouger ;
2. `AuthRepositoryImpl.signOut` renvoyait `localFailure!.message` sur une
   variable **toujours nulle**. Au premier échec réseau, cette ligne levait au
   lieu de renvoyer une erreur ; l'exception traversait le bloc, qui
   n'émettait alors aucun état — et l'attente du point 1 serait restée
   suspendue pour de bon.

### La feuille modale : deux pièges qui ne se devinent pas

`lib/core/widgets/custom_bottom_sheet.dart` porte tout ce qui monte du bas.
Deux défauts y ont vécu longtemps, et leurs causes ne sont pas celles qu'on
suppose :

1. **Le clic à l'extérieur ne fermait pas.** `BottomSheet` enveloppe son
   contenu dans un `Material` dont `absorbHitTest` vaut `true`. Comme notre
   voile flouté est plein écran, ce `Material` l'est aussi : il avale toutes
   les touches, et la barrière de la route — celle qui aurait fermé la
   feuille — n'en reçoit aucune. `isDismissible: true` n'y change rien. La
   fermeture est donc portée par le voile lui-même.

2. **La feuille restait sous le clavier.** Les métriques étaient lues sur le
   contexte *appelant*, avant l'ouverture de la route, où `viewInsets` vaut
   toujours zéro. Elles se lisent maintenant dans le `builder`, et **par
   aspect** (`viewInsetsOf`, `sizeOf`, `paddingOf`) : `MediaQuery.of`
   abonnait l'écran appelant à toutes les métriques, et le reconstruisait en
   entier à chaque trame d'ouverture du clavier.

Le flou vit dans un `RepaintBoundary`, le contenu dans un autre : sans cela,
chaque caractère tapé refloutait tout l'écran.

Un parcours en plusieurs étapes ne redessine pas sa barre : il pousse son
titre et son retour dans l'en-tête via `SheetHeaderScope.of(context)?.value`.
C'est ce que fait la connexion par e-mail et code.

### Le champ de code, et le piège du décorateur

`core/widgets/otp_code_field.dart`. Le contour d'une case est dessiné par la
case — un `Container` avec `border` — et **jamais** par l'`InputDecorator` du
champ. Avec `isDense: true` et un remplissage nul, celui-ci calcule une
hauteur bien inférieure à celle de la case : il dessinait donc son cadre sur
une fraction de la hauteur, et l'on voyait un contour en pastille posé sur un
bloc plus haut. Le champ, à l'intérieur, est en `InputBorder.none`.

L'écart entre les cases est porté par `Row(spacing:)`, pas par un
remplissage dans chaque case — sinon la dernière est plus large que les
autres de la valeur de l'écart.

### Une réussite ne se confirme pas au bouton

Le code accepté enchaîne seul : les cases restent vertes 700 ms, la
confirmation arrive, la coche se trace, et la feuille se referme. Aucun
appui. Il y avait trois gestes pour une réussite — « Suivant », « Suivant »,
« Continuer » — là où l'utilisateur n'a plus rien à décider.

`core/animation/success_check.dart` trace la coche avec un `PathMetric`
plutôt que d'afficher une icône, et **prévient quand elle a fini**
(`onFinished`) : c'est ce qui permet d'enchaîner sans qu'un appelant recopie
la durée de l'animation — une durée recopiée diverge toujours.

### Un libellé sur un aplat de couleur

Un style pris dans `textTheme` **porte sa couleur** — celle du texte de page,
sombre — et un style posé sur un `Text` l'emporte sur le `foregroundColor` du
bouton. Écrire `Text('Écrire un avis', style: textTheme.bodySmall)` dans un
`FilledButton` vert donnait donc un libellé gris foncé sur vert : illisible.
Deux boutons étaient dans ce cas.

D'où `CustomActionButton` (`core/widgets/button/`) : le bouton compact déduit
la couleur de son texte de son fond, et l'appelant ne la choisit pas.
`CustomButton` reste le bouton pleine largeur qui conclut un formulaire.

### Actions destructrices encore sans confirmation

À traiter quand l'espace commerçant sera repris — elles s'exécutent
aujourd'hui au premier doigt :

- `merchant_offers_screen.dart` — « Retirer » une offre du catalogue.
- `received_order_card.dart` — « Refuser » une commande.
- `received_reservation_card.dart` — « Refuser » une réservation.

## La carte d'offre vit dans `core/widgets`

`lib/core/widgets/offer_card.dart` est la seule carte d'offre. Les carrousels
de l'accueil, le catalogue d'un commerçant, le rail « autres offres » et la
grille d'Explorer montrent tous la même.

Une carte blanche à marge intérieure, dans laquelle la photo est posée avec
ses propres coins arrondis, et le texte occupe le bas de la carte.

**Le rayon intérieur vaut le rayon extérieur moins la marge.** Avec
`cardBorderRadius` (20) et une marge de `small` (8), il tombe sur 12. Sans
cette soustraction les deux arrondis ne sont pas concentriques, et le liseré
blanc paraît plus épais dans les coins que sur les côtés.

**La carte est bâtie en deux blocs franchement séparés** : la photo en haut,
le texte en dessous sur l'aplat de la carte. Aucun fondu, aucune
superposition, aucun voile.

C'est un choix arrêté après l'avoir essayé **quatre fois**, et chaque tentative
a produit un défaut visible :

1. **Bande basse masquée par un dégradé calculé sur l'image entière** — le
   fondu se terminait au-dessus de la bande, et le découpage tranchait une
   image déjà floutée aux trois quarts. Trait net en travers de la carte.
2. **`BackdropFilter` sur une bande** — il floute *uniformément* sa région :
   le voile se dégradait, le flou non. Même trait.
3. **Fondu exprimé en fractions de carte** (fin à 50 %) alors que le bloc de
   texte a une hauteur naturelle et commence entre 53 % et 62 % : jusqu'à
   36 px de blanc vide entre les deux.
4. **Fondu solidaire du bloc de texte** — techniquement correct, mesuré
   progressif au pixel près sur l'émulateur, mais il coûtait 48 px de photo
   sans rendre la carte plus lisible.

La leçon : la photo montre le produit, le texte le nomme. La frontière entre
les deux n'a pas besoin d'être adoucie, et chaque tentative pour l'adoucir a
coûté de la hauteur de photo.

**Le contraste n'est plus un calcul.** Le texte repose sur un aplat opaque, il
hérite donc des couples du thème : 16,7:1 pour le nom, 7,9:1 pour « chez X »,
14,7:1 pour le prix. Ces valeurs ne dépendent pas du visuel — c'est la
propriété que `test/offer_card_test.dart` protège (« le texte ne repose jamais
sur la photo »). Les versions à voile la calculaient, et le calcul a été fait
**deux fois à la mauvaise hauteur** : vérifié en bas de carte où le voile
culmine, alors que le nom est à mi-hauteur. Le titre sortait à 1,79:1.

**La photo occupe entre 49 % et 58 % de la carte** selon le gabarit — mesuré,
pas estimé. Le bloc de texte (119 px) est incompressible ; la photo prend ce
qui reste. Un test pose le plancher à 45 %.

Le contenu garde la disposition d'origine : nom, « chez qui », puis une ligne
qui oppose le prix à la note. Une version intermédiaire y avait mis trois
colonnes chiffrées (Note · Mode · Prix) : à 173 px de large dans la grille
d'Explorer, les valeurs longues rétrécissaient et les trois chiffres n'avaient
plus la même taille. La carte fait 190 px de large — pas la place pour trois
colonnes.

Les deux badges gardent aussi leurs places d'origine : le mode de retrait en
haut à gauche de la photo, la date juste au-dessus du nom — là où finissait la
photo dans la carte d'avant.

`test/offer_card_test.dart` vérifie qu'elle ne déborde ni au plus petit
gabarit du rail (190×220), ni dans une case de la grille (171×225), ni à 1,5×
d'agrandissement du texte. Les trois tailles sont réelles.

Pas de bouton dans la carte : la carte entière est le bouton. Un bouton
créerait une petite cible collée à un geste de défilement, et une offre en
boutique n'a aucune action à proposer.

## Explorer cherche des offres, et le serveur fait le tri

L'écran présentait des **commerces**, en chargeant les cinquante premiers puis
en les filtrant en Dart. Deux défauts en un : ce n'était pas le bon objet, et
au-delà de la première page le filtrage ne portait que sur ce qui était déjà
reçu.

Il s'appuie désormais sur `get-home?section=discover`, qui accepte `q`,
`category`, `minPrice`, `maxPrice`, `fulfilment`, `minRating` et `sort` — tous
appliqués **en base**. La règle : un critère qui coexiste avec du défilement
infini se filtre au serveur, jamais sur la page déjà chargée.

Deux gardes dans `ExploreCubit` méritent d'être connus :

1. **Une temporisation de 350 ms** sépare la frappe de l'appel, et un numéro
   de requête écarte les réponses arrivées dans le désordre — sans lui, une
   requête lente écrase le résultat de la recherche suivante.
2. **Le numéro de page est suivi dans l'état**, jamais déduit du nombre
   d'offres reçues. Une page n'est pleine que si le serveur avait de quoi la
   remplir ; la division redemandait la page déjà lue. Un test le tient.

`copyWith` ne peut pas remettre un critère à zéro — passer `null` veut dire
« ne change rien ». Les remises à zéro passent donc par des drapeaux
explicites (`clearPrice`, `clearCategory`…), sans quoi « tous les prix »
serait inexprimable.

## Un seul bouton icône, un seul champ de recherche

- `lib/core/widgets/button/custom_icon_button.dart` — le bouton carré qui ne
  porte qu'une icône. Il en existait quatre versions écrites à la main, avec
  trois rayons différents (10, 20, celui de `CustomCard`) et une cible
  tactile de 41 px là où `AppDimens.touchTarget` documente 48. Rayon
  `borderRadiusSmallButton`, carré, jamais sous la cible tactile. Le
  `tooltip` est **obligatoire** : une icône seule est une devinette, et c'est
  le seul texte qu'un lecteur d'écran annoncera.
- `lib/core/widgets/custom_search_field.dart` — le champ de recherche.
  L'accueil le montre en `readOnly` (il ne sert qu'à emmener sur Explorer),
  Explorer le montre éditable. Les deux doivent rester indiscernables : c'est
  le même geste poursuivi d'un écran à l'autre.

## L'adresse : six colonnes, une ligne

`user_info` porte l'adresse en **paliers** — province, ville, commune,
quartier, avenue, numéro — une ligne par utilisateur. C'est ainsi qu'une
adresse se dit à Kinshasa, et c'est ce qui permettra de grouper des livraisons
par commune sans avoir à deviner ce que contient une chaîne.

`numero` est du **texte** : « 10F » est un numéro de parcelle courant.

Province et ville sont stockées en texte et non en clé étrangère vers
`provinces`/`cities`. Le référentiel **propose**, il n'impose pas : quelqu'un
qui habite un lieu absent de la liste doit pouvoir l'écrire. Le référentiel
lui-même suit le modèle de `categories` — il vit en base, l'application n'en
connaît pas le contenu à la compilation.

À l'écran, l'adresse se lit sur **une seule ligne**, du précis au large :

> N° 10F, Av. Kasa-Vubu, Q. Lingwala, C. Gombe, Kinshasa

Les paliers absents sont omis — sans quoi une fiche à moitié remplie produit
des virgules orphelines. La ville n'est pas répétée quand elle porte le nom de
la province (Kinshasa). `test/profile_test.dart` tient ces règles.

**Le formulaire est apparié, pas empilé.** Six champs l'un sous l'autre se
lisent comme une corvée ; ils vont donc deux par deux — province avec ville,
commune avec quartier, avenue avec numéro — le numéro nettement plus étroit
puisqu'il porte trois caractères. Sous 260 px, chaque paire se remet en
colonne.

## Le rôle est verrouillé au niveau des colonnes, pas de la politique

`users` n'avait **aucune** politique UPDATE : « Modifier le profil » ne pouvait
rien enregistrer, quelle que soit l'interface. Elle existe désormais, mais le
point important est ailleurs :

```sql
revoke update on public.users from authenticated;
grant update (name, phone) on public.users to authenticated;
```

Une politique RLS ne voit pas l'ancienne ligne : elle ne peut donc pas dire
« `role` ne doit pas changer ». Le privilège de colonne, lui, l'interdit avant
même que RLS soit consulté. Sans lui, n'importe qui se promeut commerçant d'un
seul PATCH.

## Commander demande où livrer

Le commerçant recevait des commandes sans adresse : `createOrder` acceptait un
`deliveryAddress`, la colonne existait, mais `submitOrder` ne le passait
jamais.

La feuille s'ouvre **toujours**, même quand une adresse est enregistrée —
pré-remplie. On peut se faire livrer ailleurs qu'à son domicile, et une
commande partie à la mauvaise adresse sans qu'on ait demandé coûte plus cher
qu'une confirmation de trop.

Une **réservation** ne se livre pas : sa feuille demande seulement le
téléphone, et le partage reste un choix — on peut réserver sans le donner. Le
numéro voyage dans le champ `details` de la réservation.

## Une seule page de recherche

L'accueil renvoyait vers `/search` (doublon de l'onglet Explorer) et son bouton
filtre vers « Trouver selon mon budget ». Trois écrans pour une même question.
Il n'en reste qu'un : les deux contrôles de l'accueil mènent à **Explorer**, le
bouton avec le panneau de filtres ouvert.

Ce que l'accueil demande en chemin passe par **une intention**
(`ExploreCubit.pendingIntent`), pas par la route : un paramètre d'URL serait
resté après coup et aurait rejoué l'action à chaque retour sur l'onglet.
L'écran la consomme (`intentHandled()`) dès qu'il l'a traitée.

Une seule intention à la fois, et non deux drapeaux booléens : les deux gestes
s'excluent, et deux booléens auraient laissé exister un état que personne ne
peut produire.

- `focusSearch` — toucher la barre de recherche, c'est **vouloir taper**. Sans
  ce signal, l'utilisateur arrivait sur Explorer et devait toucher une seconde
  fois pour ouvrir le clavier.
- `openFilters` — le bouton ouvre le panneau à l'arrivée.

Le chercheur de budget est supprimé — sa fourchette de prix vit désormais dans
le panneau de filtres d'Explorer.


## « Tous les commerces » cherche des commerces

L'écran empruntait `HomeSearchBar`. Le nom disait « accueil », l'usage était
double : le jour où cette barre est devenue une simple porte vers Explorer,
taper dedans quittait la page — et le bouton de filtres qui l'accompagnait
ouvrait des filtres d'**offres** sur une liste de **commerces**.

La leçon vaut au-delà de ce cas : un composant nommé d'après un écran mais
utilisé par deux se casse en silence dès que l'un des deux évolue. L'écran
utilise désormais `CustomSearchField` directement, le champ partagé, sans
bouton à côté.

**La recherche est faite en base**, via `get-home?section=businesses&q=`, avec
la même temporisation de 350 ms qu'Explorer. Filtrer la page déjà reçue ne
porterait que sur les vingt premiers commerces — faux dès qu'on fait défiler.
La page suivante emporte **et** la catégorie **et** la recherche : une page qui
oublierait l'une des deux collerait des commerces sans rapport à la suite de
ceux affichés.

Changer de catégorie **conserve** le texte tapé : l'utilisateur affine, il ne
recommence pas.

Deux détails de mise en page qui traînaient : la bande de catégories était en
état étendu faute de `collapseProgress: 1`, et la liste avait des marges de 24
là où tout ce qui la surmontait était à 16 — décalée de 8 px vers l'intérieur.
Les marges de la liste et de son squelette vivent dans une seule constante,
pour qu'ils se superposent exactement.


## Le profil est une feuille, pas une page

Il rejoint les autres surfaces secondaires — filtres, confirmation, adresse de
livraison : on y jette un œil, on modifie éventuellement, on referme. Une page
plein écran pour ça obligeait à naviguer puis à revenir.

Le contenu vit dans **`ProfileDetails`**, un widget à part : la feuille
l'affiche avec un titre en tête, puisqu'elle n'a pas de barre. S'il fallait un
jour le remontrer en page, il suffit de le réenvelopper — le contenu ne serait
pas écrit deux fois, et les deux surfaces ne peuvent pas diverger.

`ProfilPage` et la route `/profil-page` sont supprimées : plus rien ne les
ouvrait.

Le fichier s'appelait `profil_page.dart` alors qu'il ne contient plus de page ;
il est devenu `profile_details.dart`. Un nom qui ment sur son contenu est
exactement ce qui a cassé la barre de recherche de « Tous les commerces » —
`HomeSearchBar` servait deux écrans, son nom n'en annonçait qu'un.


## Le mouvement a son vocabulaire, comme la couleur

`lib/core/animation/app_motion.dart` tient les durées et les courbes.
L'application en comptait **huit** (50, 120, 150, 180, 200, 220, 300, 350 ms)
et trois courbes, chacune choisie sur le moment : deux transitions voisines
n'avaient aucune raison de se ressembler. Trois durées suffisent — `quick`
pour une réaction au doigt, `base` pour le mouvement courant, `calm` pour ce
qui traverse l'écran.

**Le mouvement se demande au contexte, jamais en dur.** Quand le système est
réglé sur « réduire les animations », `AppMotion.duration()` rend zéro. Ce
réglage existe pour les personnes que le mouvement gêne — vertiges, troubles
vestibulaires — et une animation « juste jolie » ne vaut pas leur inconfort.
`test/animation_test.dart` le vérifie sur chaque composant.

### Le répertoire des interactions

| moment | composant | où |
|---|---|---|
| un contenu en remplace un autre | `FadeSwap` | Explorer, Tous les commerces, profil |
| un élément de liste arrive | `Appear` | grille d'Explorer, rails d'offres, liste de commerces |
| un nombre change | `AnimatedCount` | pastille de filtres, compteur d'activités |
| un texte change au même endroit | `SwappingText` | libellés et valeurs |
| un appui au doigt | `PressEffect` | boutons, cartes, tuiles |
| une feuille s'ouvre | `showCustomBottomSheet` | toutes les feuilles |

Trois pièges, appris en les rencontrant :

1. **`FadeSwap` exige une clé distincte par état.** Deux contenus de même type
   et de même clé sont « le même widget » pour Flutter : rien ne se croise. Un
   test le montre plutôt que de le laisser deviner.
2. **`Appear` ne joue qu'une fois.** Un élément qui rejouerait son entrée à
   chaque reconstruction clignoterait au moindre changement d'état — et sans
   arrêt pendant le défilement d'une liste recyclée.
3. **`AnimatedCount` laisse `begin` nul.** `TweenAnimationBuilder` part alors
   de la valeur courante ; le renseigner ferait aller chaque changement de la
   nouvelle valeur vers elle-même, soit aucune animation. C'est le défaut
   qu'avait la première version.

Le décalage d'entrée est **plafonné** à huit éléments : sans plafond, le
trentième attendrait plus d'une seconde et l'effet deviendrait une attente.

Une assertion posée pendant un fondu voit les deux contenus à la fois : il
faut pomper au-delà de la transition avant de mesurer.
