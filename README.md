<h1 align="center">Amgi for iOS 17</h1>

<p align="center">
  <em>암기 (amgi) — Korean for "memorization"</em>
</p>

<p align="center">
  An unofficial port of <a href="https://github.com/antigluten/amgi">Amgi</a>, the open-source, offline-first Anki-compatible flashcard app, lowered from iOS 18 to <strong>iOS 17.0</strong>.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0%2B-000000?logo=apple&logoColor=white" alt="iOS 17.0+">
  <img src="https://img.shields.io/badge/Swift-6.2-F05138?logo=swift&logoColor=white" alt="Swift 6.2">
  <img src="https://img.shields.io/badge/Rust-FFI-DEA584?logo=rust&logoColor=white" alt="Rust FFI">
  <img src="https://img.shields.io/badge/License-AGPL--3.0-blue" alt="AGPL-3.0">
</p>

---

## Credits

**iOS 17 port:** done by **Claude** (Anthropic's Claude Opus 5.5, working in
[Claude Code](https://claude.com/claude-code)) for
[Elementix](https://github.com/Elementix). Every change in the `ios17` branch
was made in that session and is listed below.

**The app itself:** everything else is the work of the upstream project.
Amgi was created by **Vladimir Gusev ([antigluten](https://github.com/antigluten))**
and its contributors (see [CONTRIBUTORS.md](CONTRIBUTORS.md) and the
[Acknowledgments](#acknowledgments)). The flashcard engine is the official
[ankitects/anki](https://github.com/ankitects/anki) Rust backend by Damien
Elmes and the Anki contributors. This fork exists only to make that work run
on a device that is staying on iOS 17. Please send bug reports that aren't
about iOS 17 upstream to https://github.com/antigluten/amgi.

## What this fork is

Upstream Amgi needs iOS 18. This fork sets the minimum to **iOS 17.0** and
replaces each iOS 18-only API with an iOS 17 fallback. On iOS 18 and later
the app still uses the original iOS 18 code paths, so it behaves exactly like
upstream there.

- **Based on:** upstream `main` at `63440c5` ("Fix lots of layout issues with
  stats and heatmap", v0.2.0 build 7).
- **Branch:** `ios17`. Every push to it builds an unsigned IPA on GitHub Actions.
- **Target setup:** an iPhone 14 Pro on iOS 17.0, jailbroken, installing with
  TrollStore. Other iOS 17 devices should work the same way, but nobody has
  tested them.

## Status

| | |
|---|---|
| Compiles for iOS 17 | ✅ [CI run 39648940425](https://github.com/Elementix/amgi/actions/runs/39648940425) (2026-10-21, commit `0166091`) built and packaged the unsigned IPA |
| Tested on a real iOS 17 device | ❌ Not yet |
| Apple Watch app | ❌ Not included (see [What's not included](#whats-not-included)) |

## Installing (TrollStore / sideloading)

1. Open the [Actions tab](https://github.com/Elementix/amgi/actions), click the
   latest successful **Build Unsigned IPA** run on `ios17`, and download
   **AmgiApp-unsigned-ipa** from the Artifacts section. GitHub delivers it as a
   `.zip` with the `.ipa` inside. Artifacts expire after **7 days**. To get a
   fresh one, re-run the workflow (**Run workflow**, branch `ios17`).
2. Unzip it and open `AmgiApp-unsigned.ipa` with **TrollStore**. Any other
   sideloading tool (AltStore, Sideloadly, …) works as well. Those re-sign the
   app with your Apple ID.

The IPA is **unsigned** and has **no entitlements** embedded, because CI builds
it with code signing turned off. See [Known differences](#known-differences-on-ios-17)
for what that changes.

## Getting decks in (e.g. AnkiWeb shared decks)

Amgi reads standard Anki packages (`.apkg` for decks, `.colpkg` for whole
collections).

1. On the iPhone, open the shared deck's page on
   [ankiweb.net](https://ankiweb.net/shared/decks) in Safari and tap
   **Download**. Save the `.apkg` to the Files app.
2. In Amgi, go to **Library** and choose **Import**, then pick the `.apkg`.
3. Repeat for each deck.

You can also skip files and sync: sign in to AnkiWeb (or a self-hosted sync
server) in the app and sync a collection you already have.

## Every change from upstream

All changes are in the commits on `ios17` on top of `63440c5`. Run
`git diff 63440c5 ios17` for the exact diff.

### Deployment target

| File | Change |
|---|---|
| `AmgiApp/project.yml` | `deploymentTarget.iOS` `18.0` → `17.0` |
| `Package.swift`, `AmgiFeatures/Package.swift`, `AmgiUI/Package.swift`, `AmgiReader/Package.swift` | `.iOS(.v18)` → `.iOS(.v17)` |

`scripts/build-xcframework.sh` already built the Rust engine with
`IPHONEOS_DEPLOYMENT_TARGET=17.0`, so the Rust side didn't change. The watchOS
and macOS minimums in the package manifests stayed as they were.

### Dependencies that declared a higher minimum

The first CI build stopped before compiling any Swift, because Swift Package
Manager rejected two dependencies:

| Dependency | Problem | Fix |
|---|---|---|
| `Libraries/EPUBKit` (vendored EPUB parser) | `The package product 'AEXML' requires minimum platform version 17.0 for the iOS platform, but this target supports 16.0` | Raised EPUBKit's `.iOS(.v16)` to `.iOS(.v17)`. |
| [hoshidicts](https://github.com/Manhhao/hoshidicts) (C++ Yomitan dictionary engine, used by the Reader's dictionary lookup) | Its own `Package.swift` declares `.iOS(.v18)`, so no iOS 17 target can depend on it. | New `scripts/vendor-hoshidicts.sh` clones the same pinned revision (`e70589d`) with its submodules into `Libraries/hoshidicts/` (gitignored) and changes that one line to `.iOS(.v17)`. `AmgiReader/Package.swift` now uses `.package(path: "../Libraries/hoshidicts")` instead of the Git URL, and the stale remote pin was removed from `Package.resolved`. hoshidicts' source is unchanged. |

### iOS 18-only APIs and their replacements

| Where | iOS 18 API | Change for iOS 17 |
|---|---|---|
| `Sources/AnkiBackend/AnkiBackend.swift` | `Mutex` (Synchronization framework) | Replaced with `OSAllocatedUnfairLock` (iOS 16+), which has the same `withLock` shape. Same behavior on every iOS version. |
| `AmgiFeatures/Sources/RootFeature/MainTabView.swift` | `TabView` + `Tab(_:systemImage:value:)` builder | iOS 18+ keeps the `Tab` builder. iOS 17 uses `.tabItem` + `.tag` with the same five tabs, icons and selection. The tab contents moved into shared private properties so both paths render the same views. |
| `AmgiFeatures/Sources/ReaderFeature/Reader/Library/AllBooksSection.swift`, `ContinueReadingSection.swift` (+ new `CoverZoomTransition.swift`) | `.navigationTransition(.zoom…)`, `.matchedTransitionSource` | New `coverZoomDestination` / `coverZoomSource` modifiers. iOS 18 gets the zoom-from-cover animation. iOS 17 gets the standard push. |
| `AmgiFeatures/Sources/StatsCharts/HeatmapChartOptimized.swift` | `.onScrollGeometryChange` | iOS 18 is unchanged. iOS 17 reads the scroll offset with a `GeometryReader` + `PreferenceKey` in a named coordinate space, so the heatmap still loads older history as you scroll. |
| `AmgiFeatures/Sources/BrowseFeature/BrowseView.swift`, `ReaderFeature/Reader/ReaderLibraryView.swift` | `.searchFocused(_:)` | Gated behind `#available`. On iOS 17 the **Find** (⌘F) menu command doesn't move focus into the search field. Only hardware keyboards are affected. Tapping the search field works normally. |
| `AmgiUI/Sources/UI/DeckDetail/DeckHeroTile.swift` | `Color.mix(with:by:in: .perceptual)` | iOS 18 is unchanged. iOS 17 does a linear sRGB blend of the two resolved colors, so deck hero-tile gradients may look slightly different. |
| Image-occlusion screens, EPUB reader, Study landing | `.toolbarVisibility(_:for:)` | Replaced with the equivalent `.toolbar(_:for:)` (iOS 16+). Same behavior on every version. |
| `AmgiFeatures/Sources/IntentsFeature/StudyDeckIntent.swift` | `OpenURLIntent` | The **Study Deck** Shortcut used to return `OpenURLIntent(amgi://review?deckId=…)`. It now calls `UIApplication.shared.open` on that URL from inside the app instead. The intent already has `openAppWhenRun = true`, so the app is in the foreground first. This applies on every iOS version. |

APIs that are back-deployed and needed no change: `@Entry`,
`onGeometryChange(for:of:action:)`. Code already behind `#available(iOS 26, *)`
(Liquid Glass materials and similar) needed no change either. On iOS 17 it
takes its existing pre-iOS-26 fallback.

### CI (`.github/workflows/build-ipa.yml`)

- Added a `push` trigger for the `ios17` branch, so every push builds an IPA.
- Removed the simulator "compatibility smoke check" step to make runs faster.
  The device archive step compiles the same code.
- Added a **Vendor hoshidicts for iOS 17** step that runs
  `scripts/vendor-hoshidicts.sh` before the Xcode project is generated.
- Added a **Report compile errors** step. It runs only when the build fails,
  and copies each `error:` line from the build log into an annotation. Job
  logs are visible only to signed-in users, but annotations show on the public
  run page.
- Switched the runner from `macos-26` (Apple Silicon) to `macos-26-intel`
  (Intel, same macOS 26 and Xcode 26.3). The Apple Silicon pool failed to
  assign a machine three times in a row ("capacity constraints"). The Rust
  engine is cross-compiled for the iPhone's ARM chip either way. The time
  limit went from 60 to 120 minutes because Intel runners are slower, and the
  Rust cache key now includes the CPU architecture.
- Everything else matches upstream: Xcode 26.3, Rust 1.95, unsigned archive,
  and an IPA uploaded as a 7-day artifact.

## Known differences on iOS 17

- **Tab bar:** iOS 17 uses the classic tab bar API. Same tabs and icons. The
  look follows iOS 17's system style.
- **Reader:** opening a book slides in instead of zooming out of its cover.
- **Deck tiles:** gradient colors may differ slightly (see the `Color.mix` row above).
- **⌘F:** with a hardware keyboard, it doesn't focus the search field.
- **Anything already gated to iOS 26** (Liquid Glass and similar) uses its
  existing non-glass fallback. The same is true for upstream on iOS 18.
- **Home-screen widget (unsigned / TrollStore installs):** the widget and app
  share data through the App Group `group.com.amgiapp`. The unsigned IPA has
  no entitlements, so that group isn't granted. The app falls back to its own
  storage and runs normally, but the widget probably won't see your due counts.
  Studying, syncing and importing don't use the App Group container.
- **Shortcuts/Siri:** the actions are still there, but nobody has tested them
  on iOS 17 yet.

## What's not included

- **Apple Watch app.** Upstream has one, but the CI workflow only builds the
  iPhone app scheme and doesn't embed the watch app in the IPA. This fork made
  no watchOS changes.
- **Screenshots.** The upstream screenshots in `assets/` show the iOS 18/26
  look and aren't representative here, so this README doesn't use them.

## Building it yourself

You need a Mac with **Xcode 26**, Rust (stable *and* nightly with `rust-src`,
because `build-xcframework.sh` also builds a watchOS slice), `protobuf`,
`swift-protobuf` and `xcodegen`. Upstream's
**[Documentation/BUILDING.md](Documentation/BUILDING.md)** has the details.

```bash
git clone --recursive -b ios17 https://github.com/Elementix/amgi.git
cd amgi
./scripts/build-xcframework.sh            # Rust engine → xcframework
./scripts/generate-protos.sh              # protobuf → Swift types
./scripts/vendor-hoshidicts.sh            # iOS 17 copy of hoshidicts (this fork only)
cd AmgiApp && xcodegen generate && cd ..  # project is generated, not checked in
open AmgiApp/AmgiApp.xcodeproj
```

If you don't have a Mac, use the GitHub Actions workflow. It runs on Apple's
macOS runners.

### Gotcha: cloning on Windows

The repo contains `anki-bridge-rs/src/aux.rs`, and `aux` is a reserved device
name on Windows. A normal `git clone` fails at checkout with
`invalid path 'anki-bridge-rs/src/aux.rs'`. To edit the repo on Windows
anyway, clone with `--no-checkout`, check out every file except that one, and
mark it `skip-worktree`. Commits then keep the file unchanged:

```bash
git clone --no-checkout -b ios17 https://github.com/Elementix/amgi.git && cd amgi
git config core.protectNTFS false
git reset -q                          # fill the index without touching the disk
git ls-files -z | tr '\0' '\n' | grep -v '^anki-bridge-rs/src/aux.rs$' | git checkout-index -f --stdin
git update-index --skip-worktree anki-bridge-rs/src/aux.rs
```

You still can't *build* on Windows, so push and let CI build it.

## Keeping up with upstream

```bash
git remote add upstream https://github.com/antigluten/amgi.git
git fetch upstream
git rebase upstream/main      # on the ios17 branch
```

After a rebase, look for new iOS 18 APIs that upstream may have added. The
CI build fails with `'…' is only available in iOS 18.0 or newer` for each
one. Gate it with `if #available(iOS 18, *)` and an iOS 17 fallback, the same
way as in the table above.

## Architecture (unchanged from upstream)

```
SwiftUI feature modules (AmgiFeatures)
    |
@DependencyClient structs (AnkiClients)
    |
Service facades (AnkiServices)
    |
Typed protobuf requests (AnkiProtoBridge)
    |
AnkiBackend (Swift wrapper)
    |
C FFI (4 functions)
    |
Rust dynamic framework (ankitects/anki rslib)
```

Swift owns the UI. Rust owns everything else: database, sync, FSRS
scheduling, card templates, search, import/export and statistics. Upstream's
docs cover the rest: [Features](Documentation/FEATURES.md),
[Architecture](Documentation/ARCHITECTURE.md),
[Rust bridge](Documentation/RUST_BRIDGE.md),
[Data flows](Documentation/DATA_FLOWS.md),
[Changelog](CHANGELOG.md).

## License

**GNU Affero General Public License v3.0 (AGPL-3.0)**, the same as upstream
Amgi. It incorporates [ankitects/anki](https://github.com/ankitects/anki)
(copyright Ankitects Pty Ltd), which is also AGPL-3.0. See [LICENSE](LICENSE).
The complete source for this port, including all iOS 17 changes, is this
repository's `ios17` branch. The Reader's dictionary engine,
[hoshidicts](https://github.com/Manhhao/hoshidicts), is GPL-3.0. The build
fetches it from its own repository, and the only change is its minimum iOS
version.

## Acknowledgments

From upstream, kept as-is:

- **[Vladimir Gusev (antigluten)](https://github.com/antigluten)**, creator of Amgi
- **[Damien Elmes](https://github.com/dae)** and the [ankitects/anki](https://github.com/ankitects/anki) contributors, for the Rust backend that powers this app
- **[DreamAfar](https://github.com/DreamAfar)**, for the v0.0.3 fork that contributed Image Occlusion, the multi-theme system, the Settings tab, the card template editor, retrievability stats, tag management, the rich note editor, and the GitHub Actions IPA workflow
- **[AnkiDroid](https://github.com/ankidroid/Anki-Android)**, for pioneering the Rust backend bridge pattern on mobile
- **[Point-Free](https://www.pointfree.co/)**, for [swift-dependencies](https://github.com/pointfreeco/swift-dependencies)
- **[Manhhao](https://github.com/Manhhao)**, for [hoshidicts](https://github.com/Manhhao/hoshidicts), the Reader's dictionary engine

iOS 17 port: **Claude** (Anthropic), via Claude Code, for Elementix.
