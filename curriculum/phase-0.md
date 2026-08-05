# Phase 0: Setup / project config

## Approach

Before any feature work, the project needs to actually match the stack
described in the app spec. Right now `pubspec.yaml` only has `flutter`,
`cupertino_icons`, and `flutter_lints`, and `lib/main.dart` is still the
default counter-app template. This phase is pure setup: get the real
dependencies in, clear out the template code, and settle on a folder
structure that the rest of the phases will build into. No feature logic
happens here.

## Libraries / tools used this phase

- Flutter / Dart tooling (`flutter pub get`, `flutter create` conventions) — [docs](https://docs.flutter.dev)
- `flutter_riverpod` — [docs](https://riverpod.dev)
- `go_router` — [docs](https://pub.dev/packages/go_router)
- `shadcn_ui` — [docs](https://flutter-shadcn-ui.mariuti.com)
- `flutter_animate` — [docs](https://pub.dev/packages/flutter_animate)
- `image_picker` — [docs](https://pub.dev/packages/image_picker)

## Required knowledge

No concepts from the graph are assumed yet — this phase is project
configuration, not app logic.

## Features

This phase has no user-facing features. Tasks instead of features:

- Add `flutter_riverpod`, `go_router`, `shadcn_ui`, `flutter_animate`, and
  `image_picker` to `pubspec.yaml` and run `flutter pub get`.
- Replace the default counter-app contents of `lib/main.dart` with a minimal
  app entrypoint (still fine to be a near-empty `MaterialApp`/`ShadApp` at
  this point — Phase 1 is where real screens start appearing).
- Decide on and create a `lib/` folder structure that separates models,
  repositories, providers, routing, and screens (exact names are your call —
  this curriculum will refer to them generically as "the models folder,"
  etc.).
- Confirm the app still builds and runs on at least one target before moving
  on.

## Checklist

- [ ] 0.1 Dependencies added and `flutter pub get` succeeds
- [ ] 0.2 Counter-app boilerplate removed from `lib/main.dart`
- [ ] 0.3 Folder structure decided and created
- [ ] 0.4 App builds and runs
