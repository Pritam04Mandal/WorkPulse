# WorkPulse — build handoff (Phase 1)

Context for whoever continues the Flutter build (local Claude Code or a person).

## Designs
- Canvas: https://claude.ai/artifact/YNF37ooFtoH4Rq3DEYAMdm — 21 clickable phone screens + a flow map at the top.
- Look: deep charcoal `#0E0F11` background, surface `#16181B`, border `#23262B`/`#2A2E34`, text `#E6E8EB`, muted `#8B919A`, single accent teal `#3DD6B0` (text on accent `#0B0C0E`).
- Category colours: coding `#6EA8FE`, AI `#B49CFF`, meetings `#F0A35E`, other `#4A4F57`. Amber `#F0A35E` also marks inferred/sample data. Destructive `#C9473D` / `#FF8A80`.
- Type: Inter for UI, JetBrains Mono for durations, counts and identifiers.
- Observed events = solid dot; inferred = outlined dot + "inferred NN%" in amber. Every sample-data screen shows a `SAMPLE DATA` chip.
- Bottom nav: Home, Timeline, Projects, Insights, Settings. Integrations reached from Settings and a Home shortcut.

## Findings from research (Nov 2026)
- **google_sign_in 7.x** (latest 7.2.0): singleton `GoogleSignIn.instance`; `initialize(clientId:, serverClientId:)`, listen to `authenticationEvents`, call `attemptLightweightAuthentication()` for session restore, `authenticate()` from a button (check `supportsAuthenticate()`). Scopes are no longer passed at init; extra scopes go through `user.authorizationClient`. An Android idToken needs `serverClientId` = the Web client ID from Google Cloud.
- **msal_auth 3.5.3**: `SingleAccountPca.create(clientId:, androidConfig: AndroidConfig(configFilePath: 'assets/msal_config.json', redirectUri: 'msauth://<package>/<sigHash>'))`; `acquireToken(scopes:, prompt:)`, `acquireTokenSilent(scopes:)`, `currentAccount`, `signOut()`. Exceptions: `MsalUserCancelException`, `MsalUiRequiredException`, `MsalNoCurrentAccountException`, etc. `AuthenticationResult` has `idToken`, `tenantId`, `account.id` (use as stable subject id).
  - Android needs `BrowserTabActivity` in the manifest with `msauth` scheme, host = package name, path = `/<base64 signature hash>` (use a manifest placeholder per build type).
  - The app's Gradle repositories must include Microsoft's feed: `https://pkgs.dev.azure.com/MicrosoftDeviceSDK/DuoSDK-Public/_packaging/Duo-SDK-Feed/maven/v1`.
  - Plugin is built with compileSdk 36, minSdk 21, AGP 8.11.1, Kotlin 2.2.20.
- **drift** latest 2.35.3 (use with drift_dev + build_runner; drift_flutter for `driftDatabase()`).
- Client IDs, redirect URI and signature hash should come from `--dart-define` / Gradle properties, never committed. If unset, the Google/Microsoft buttons show a "not configured" error state instead of crashing.

## Integration feasibility (answered earlier)
- Free, no backend needed: GitHub.com (device flow), GitHub Enterprise Server (`https://<host>/api/v3`, device flow, per-instance OAuth app), GitLab.com and self-managed (PKCE or device grant ≥17.1, per-instance app), Microsoft Graph calendar via MSAL (tenant may require admin consent), Google Calendar (sensitive scope: verification, no security assessment).
- Gmail: every read scope, including `gmail.metadata`, is restricted → verification + annual CASA assessment; 100-test-user cap until then. Leave out for now; Android usage already captures Gmail app time.

## Phase 1 checklist (from the spec)
1. Flutter Android project, package e.g. `com.workpulse.app`.
2. Feature-first clean architecture per spec §7; Riverpod DI; go_router with a `StatefulShellRoute` for the 5 tabs.
3. Theme from the tokens above.
4. Onboarding: Welcome → Sign-in → Usage Access explainer → Home.
5. Auth: Google, Microsoft, local/anonymous; persist the `users` row (local UUID, provider, subject id, name, email, photo, createdAt, lastLoginAt); tokens only in flutter_secure_storage; never log tokens.
6. Drift DB with all spec §6 tables, indexes, migration strategy + migration test.
7. Dashboard with clearly labelled sample data.
8. `flutter analyze`, tests, `flutter build apk --debug`.

## Not yet done
No code written yet. This session's network blocked pub.dev, Google Maven, Gradle and the Flutter SDK, so building continues on the user's machine.
