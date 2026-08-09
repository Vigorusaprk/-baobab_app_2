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

- `get-home` — paginated business list (`?category=&q=&page=&pageSize=`)
- `get-business-detail` — `?id=` → `{business, menuItems, rooms, vehicles, reviews}`
- `get-reviews-business` — `?businessId=&page=`
- `create-review`
- `get-orders-client` — paginated, server-enriched with menu/business names
- `get-reservations-client` — paginated, server-enriched with business name
- `create-order`, `update-order-status`
- `create-reservation`, `delete-reservation`
- `get-me` — merges `auth.users` + `public.users`, auto-creates the `public.users` row on first login. **Casing gotcha**: the supabase-js `User` object from `auth.users` uses **snake_case** properties (`user_metadata`, `email_confirmed_at`, `created_at`), not camelCase — a real bug hit and fixed while building this function.

If a screen needs a new kind of server-side data (a new page's initial load, a new mutation), add a new Edge Function following the naming convention above rather than reaching for a direct `.from()` call, even for something that looks like a "simple" query.

### Database performance rules already applied

RLS policies use `(select auth.uid())` rather than a bare `auth.uid()` (avoids per-row re-evaluation), multiple-permissive-policy tables were consolidated into single policies, and every foreign key has a covering index. Keep this pattern in any new policy/migration, and check `mcp__supabase__get_advisors` after schema changes.

## Pagination — Infinite Scroll Pattern

Lists that page through server data (currently: the home page's business carousel) use **infinite scroll**, not page-number controls. The pattern, established in `home_page/presentation/bloc/business_bloc.dart` + `home_page/presentation/widgets/business_cards_widget.dart`, must be followed for any new paginated list:

- **All pagination state and logic lives in the Bloc** — `page`, `hasMore`, `isLoadingMore` fields on the loaded state, plus a dedicated `LoadMore...` event that guards against duplicate/concurrent loads (`state is! XLoaded || !state.hasMore || state.isLoadingMore` → no-op).
- **The widget only reports proximity to the end of the loaded list** (e.g. `if (index == items.length - 2) context.read<XBloc>().add(const LoadMoreX());`) — it must not compute page numbers, track `hasMore`, or otherwise know anything about pagination itself. This separation is a hard requirement, not a nice-to-have.
- A failed "load more" call fails silently and resets `isLoadingMore` so the user can simply keep scrolling to retry — don't surface a blocking error dialog/snackbar for a background page fetch.
- The remote data source returns a small record/DTO like `({List<T> items, bool hasMore})`; the domain layer wraps that in a proper named class (e.g. `BusinessesPage`) rather than leaking the raw record above the data layer.

## Loading States — Skeletonizer, Not Spinners

Full-page and full-section loading states use the `skeletonizer` package, **not** `CircularProgressIndicator`. Reference implementation: `home_page/presentation/screens/home_page_screen.dart` + `home_page/presentation/widgets/home_skeleton.dart`.

Rules:

- Wrap the loading branch in `Skeletonizer(enabled: isLoading, child: ...)`.
- Build the skeleton from **explicit `Bone` widgets** (`Bone`, `Bone.text(words:/width:, style:)`, `Bone.multiText(lines:, style:)`, `Bone.circle(size:)`, `Bone.button(...)`) that mirror the real loaded layout section-by-section. Do **not** rely on Skeletonizer's auto-detection from plain `Container`/`Text` — it was tried and rejected because the resulting shape didn't read correctly; explicit `Bone`s are the only accepted approach here.
- Name/locate the skeleton widget next to the real widget/screen it mirrors so the mapping is obvious — e.g. `business_detail_skeleton.dart` for `business_detail_screen.dart`, `profile_skeleton.dart` for `profil_page.dart`, `activity_skeleton.dart` for `activity_screen.dart`.
- This covers **whole-page loading states**, and any in-page content-loading spinner that behaves the same way (e.g. a `FutureBuilder` fetching a sub-section's data, like the reviews list inside `review.dart`).
- It does **not** cover action-in-progress overlays (submitting a reservation, placing an order, saving a form) — those block already-loaded content while a write request is in flight, which is a different UX than "this shape is about to fill in with content." Those may keep a `CircularProgressIndicator`, typically as a semi-transparent overlay.
- Infinite-scroll "load more" indicators must also be skeleton-based: append a trailing skeleton item shaped like the real list/card item (reuse the existing item skeleton widget) while `isLoadingMore` is true, instead of a spinner or no indicator at all.

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
12. Any new full-page or full-section loading state must use `Skeletonizer` + explicit `Bone` widgets mirroring the real layout — never a bare `CircularProgressIndicator` for content loading. The one exception is action-in-progress overlays (submit/save while content is already loaded) — see "Loading States — Skeletonizer, Not Spinners" above.
13. **`lib/core/themes/app_theme.dart` (`AppTheme.silvaTheme`) is the single source of truth for the app's `ThemeData`.** The app currently ships one theme only (light — `brightness: Brightness.light`, no `darkTheme` wired into `MaterialApp.router`). When a task calls for visual/theming work:
    - Never invent a one-off color palette or a screen-specific "look" (e.g. a dark card style copied from a design mockup) that doesn't route through `AppColors`/`AppTheme`. If a design reference (mockup, screenshot) implies colors that don't exist in `AppColors`, restyle the layout using the existing palette instead of introducing new literals — ask the user first if the existing palette genuinely cannot express the design.
    - If a real second theme (e.g. an actual dark mode) is ever needed, it must be added properly: new tokens in `AppColors`, a second `ThemeData` in `AppTheme`, and `darkTheme`/`themeMode` wired into `MaterialApp.router` in `lib/app/main_app.dart` — not a scoped-to-one-screen imitation. Don't half-build this (e.g. a theme picker UI that stores a `ThemeMode` nobody consumes) — a `SettingsCubit.themeMode` + theme-picker dialog like this existed and was removed for being fully decorative; don't reintroduce that pattern.

## UI And Design System

A dedicated design system pass (colors, typography, spacing, component consistency) is planned but has **not started**. Until a `ui-design-systems` reference file exists in this repo, do not perform a broad visual redesign — only make the minimal visual changes required by the task at hand, using the existing `AppColors`/`AppDimens`/`AppFonts` constants under `lib/core/themes`, and never colors/styles outside of what `AppTheme.silvaTheme` (`lib/core/themes/app_theme.dart`) already defines or composes from those constants (see rule 13 above).
