# WorkPulse

Understand your working day without keeping a work log. An Android app built
with Flutter that keeps everything on the device and records metadata only.

Design canvas: https://claude.ai/artifact/YNF37ooFtoH4Rq3DEYAMdm
Build notes: [build-handoff.md](build-handoff.md)

## Status

Every design screen is built. Onboarding, sign-in, Profile, sign-out and
Delete all data are real. Everything marked `SAMPLE DATA` uses in-memory
examples until the integrations land: Android usage tracking first, then
GitHub, Teams and the paired devices.

The database tables other than `users` were derived from the design canvas,
because the original spec's §6 was not available. See `lib/core/database/tables.dart`.

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

## Sign-in configuration

Without these the Google and Microsoft buttons show a "not configured" state.
Never commit real values. `dart_defines*.json` is git-ignored.

```json
{
  "GOOGLE_SERVER_CLIENT_ID": "<web client id>.apps.googleusercontent.com",
  "MSAL_CLIENT_ID": "<azure application id>",
  "MSAL_REDIRECT_URI": "msauth://com.workpulse.app/<url-encoded signature hash>"
}
```

```sh
flutter run --dart-define-from-file=dart_defines.json
```

Microsoft also needs the signature hash for its redirect activity, in
`~/.gradle/gradle.properties`:

```properties
workpulse.msalSignatureHash.debug=<base64 hash>
workpulse.msalSignatureHash.release=<base64 hash>
```
