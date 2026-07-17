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

## UI And Design System

A dedicated design system pass (colors, typography, spacing, component consistency) is planned but has **not started**. Until a `ui-design-systems` reference file exists in this repo, do not perform a broad visual redesign — only make the minimal visual changes required by the task at hand, using the existing `AppColors`/`AppDimens`/`AppFonts` constants under `lib/core/themes`.
