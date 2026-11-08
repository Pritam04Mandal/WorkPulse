# WorkPulse

Understand your working day without keeping a work log. An Android app built
with Flutter that keeps everything on the device and records metadata only.

Design canvas: https://claude.ai/artifact/YNF37ooFtoH4Rq3DEYAMdm
Build notes: [build-handoff.md](build-handoff.md)

## Status

Every design screen is built. Android usage tracking drives Home, Timeline,
Activity detail and app exclusions, and it catches up from Android's usage log
each time the app opens. Onboarding, sign-in, Profile, sign-out, Private
session and Delete all data are also real. Everything marked `SAMPLE DATA`
uses in-memory examples until Teams and the paired devices land. GitHub
connects with Device Flow and syncs commits, pull requests, reviews and issues.

The database tables other than `users` were derived from the design canvas,
because the original spec's §6 was not available. See `lib/core/database/tables.dart`.

## Claude Code

`companion/claude-code/workpulse_claude.py` reports Claude Code session times
to the phone over the local network. It needs only Python 3.8+. Open
**Integrations → Claude Code** in the app for the pairing commands. Sessions
send only times, the folder name and the repository name; events are signed
but not encrypted on the local network.

## VS Code

`companion/vscode` is a dependency-free extension that sends coding time over
the same pairing. Package it with
`npx @vscode/vsce package --allow-missing-repository --skip-license`.

## Layout

```
lib/app/             router, bottom-nav shell
lib/core/            theme tokens, database, shared widgets
lib/features/<name>/ domain, data, presentation
drift_schemas/       committed schema dumps, one per version
```

## Commands

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
dart run build_runner build   # after changing tables
```

To change the schema: edit `tables.dart`, bump `schemaVersion`, run
`dart run drift_dev make-migrations`, and wire the generated steps into
`AppDatabase.migration`.

## Credentials

All client IDs and signature hashes live in `.env` at the project root, which
is git-ignored. Anything left empty shows as "not configured" in the app.

| Key | Where it comes from |
| --- | --- |
| `GITHUB_CLIENT_ID` | GitHub OAuth App with Device Flow enabled |
| `GOOGLE_SERVER_CLIENT_ID` | Google Cloud, Web OAuth client |
| `MSAL_CLIENT_ID` | Azure App registration |
| `MSAL_REDIRECT_URI` | `msauth://com.workpulse.app/<url-encoded signature hash>` |
| `MSAL_SIGNATURE_HASH_DEBUG` | Base64 hash of the debug signing key |
| `MSAL_SIGNATURE_HASH_RELEASE` | Base64 hash of the release signing key |

```sh
flutter run --dart-define-from-file=.env
```
