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
  <a href="https://github.com/Elementix/amgi/releases/latest"><img src="https://img.shields.io/github/v/release/Elementix/amgi?label=release" alt="Latest release"></a>
</p>

<p align="center">
  <strong>✅ Working on iOS 17.</strong> <a href="https://github.com/Elementix/amgi/releases/latest/download/AmgiApp-unsigned.ipa">Download the IPA</a> · <a href="#installing-trollstore--sideloading">Install</a> · <a href="#getting-decks-in-eg-ankiweb-shared-decks">Import decks</a>
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
- **Compatibility:** iOS **17.0 or later** (the IPA's `MinimumOSVersion` is
  17.0). It's meant for devices that are staying on iOS 17. It also installs
  on iOS 18/26, but there it adds nothing over upstream.
- **Tested on:** an iPhone 14 Pro on iOS 17.0, jailbroken, installed with
  TrollStore. Other iOS 17 devices should work the same way, but nobody has
  tested them yet.

## Status

**The iOS 17 port works.** Release
[`v0.2.1-ios17`](https://github.com/Elementix/amgi/releases/tag/v0.2.1-ios17)
is the build that was tested on the device. It was confirmed on an iPhone 14
Pro (iOS 17.0) to:

- ✅ install with TrollStore and launch
- ✅ run the onboarding flow and open a local collection (**Use Locally**)
- ✅ show the main tab bar and screens without crashing
- ✅ import AnkiWeb `.apkg` decks, both from **Library → ⋯ → Import Deck…**
  and from Safari/Files via **Share → Amgi**
- ✅ import EPUBs (**Read → Import EPUB…**) and open them in the reader

| | |
|---|---|
| iOS 17.0 | ✅ Tested on device |
| iOS 17.1 – 17.x | Should work (same code paths as 17.0), not tested yet |
| iOS 18 and later | Installs and runs upstream's original iOS 18 code paths. Not tested with this fork. On iOS 18+ you're better off with [upstream Amgi](https://github.com/antigluten/amgi). |
| Apple Watch app | ❌ Not included (see [What's not included](#whats-not-included)) |
| CI | ✅ Builds an unsigned IPA on every push to `ios17` ([latest runs](https://github.com/Elementix/amgi/actions)) |

Getting there took three on-device fixes, all described below: the
[`.tag()` crash](#the-tag-crash-found-on-device), the
[async-closure crash](#the-async-closure-crash-found-on-device), and
[deck import](#deck-import).

## Installing (TrollStore / sideloading)

1. Download `AmgiApp-unsigned.ipa` from the
   [latest release](https://github.com/Elementix/amgi/releases/latest). The
   release page also lists its SHA-256.
2. Install it:
   - **TrollStore** (iOS 17.0 on supported devices): open the `.ipa` with
     TrollStore. It installs permanently, and updates install over the
     top without losing your decks.
   - **AltStore / Sideloadly / similar** (any iOS 17+ device): sign it with
     your Apple ID. A free Apple ID install expires after 7 days. A paid
     developer account lasts a year.

Builds of `ios17` newer than the release (not device-tested) are under the
[Actions tab](https://github.com/Elementix/amgi/actions). Open the latest
successful **Build Unsigned IPA** run and download **AmgiApp-unsigned-ipa**
(a `.zip` with the `.ipa` inside, kept for 7 days).

The IPA is **unsigned** and has **no entitlements** embedded, because CI builds
it with code signing turned off. See [Known differences](#known-differences-on-ios-17)
for what that changes.

## Getting decks in (e.g. AnkiWeb shared decks)

Amgi reads standard Anki packages (`.apkg` for decks, `.colpkg` for whole
collections).

1. On the iPhone, open the shared deck's page on
   [ankiweb.net](https://ankiweb.net/shared/decks) in Safari and tap
   **Download**.
2. Then either:
   - tap the download (or the file in the Files app), tap **Share**, and pick
     **Amgi**; or
   - in Amgi, go to **Library**, tap **⋯** (top right), choose
     **Import Deck…**, and pick the `.apkg`.
3. A banner shows the import progress and how many notes were added.

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

### The `.tag()` crash (found on device)

The first build compiled cleanly but crashed on iOS 17 as soon as the main
tab bar appeared. The crash was `EXC_BAD_ACCESS` at address `0x0`, on a
SwiftUI AttributeGraph thread that was reading a view's type layout.

Built with the iOS 18+ SDK, every `.tag(_:)` call compiles to
`ModifiedContent<…, _TagTraitWritingModifier<V>>`. That type doesn't exist in
iOS 17's SwiftUI: it's missing from the iOS 17.0 and 17.5 SDK symbol lists,
which only have the older `_TraitWritingModifier`. The compiler doesn't flag
it, but at runtime its type descriptor resolves to null. SwiftUI crashes on
any view that contains a `.tag()`, including the iOS 17 tab bar fallback and
about 70 pickers across Settings, deck options, the Reader and the editors.

Fix: a new `amgiTag(_:)` helper in `AmgiUI/Sources/Theme/AmgiTag.swift`
replaces every `.tag(_:)` in the iPhone app. It wraps the view in one-element
`ForEach`es, which SwiftUI tags with their `id` using the running OS's own
mechanism. It tags with both `V` and `V?`, matching the newer `.tag()`'s
`includeOptional` behavior, so optional selections keep working. It
behaves the same on iOS 17, 18 and 26, so no availability check is needed.
The watch app's `.tag()` calls are untouched, since the watch app isn't built.

How it was found: the crashing build's binary (UUID matched the crash log)
was checked against Apple's iOS 17.0 SDK symbol lists. 11 symbols referenced
from Swift type metadata are missing on iOS 17. 9 are the guarded iOS 18/26
types above, which only appear inside their `#available` branches (erased to
`AnyView`). One is preview-only. The last was `_TagTraitWritingModifier`.

APIs that are back-deployed and needed no change: `@Entry`,
`onGeometryChange(for:of:action:)`. Code already behind `#available(iOS 26, *)`
(Liquid Glass materials and similar) needed no change either. On iOS 17 it
takes its existing pre-iOS-26 fallback.

### The async-closure crash (found on device)

With `.tag()` fixed, the next build (`72ffd70`) still crashed when the main
screen first appeared. It was the same `EXC_BAD_ACCESS` at `0x0` inside
AttributeGraph's type-layout walk, but this time the return address pointed
into a metadata accessor in the app itself. That accessor called
`swift_getExtendedFunctionTypeMetadata`, a Swift runtime function that only
exists in iOS 18+. It's weak-linked, so on iOS 17 it's a null pointer.

Upstream enables the Swift 6.2 upcoming feature
`NonisolatedNonsendingByDefault` in every package manifest and in the app
target. Under it, every `async` closure type (`() async -> Void`,
`@Sendable (CardID) async throws -> Void`, and so on) becomes
`nonisolated(nonsending)`. The runtime can only describe that kind of type
through the extended function type metadata. Views and `@DependencyClient`
structs store dozens of those closures, so the app crashes the first time
SwiftUI looks at them. The compiler gives no warning for an iOS 17 target.
The binary had 54 call sites, 52 of them with the `nonsending` flag.

Fix: `NonisolatedNonsendingByDefault` is removed from `Package.swift`,
`AmgiFeatures/Package.swift`, `AmgiUI/Package.swift`,
`AmgiReader/Package.swift` and `OTHER_SWIFT_FLAGS` in `AmgiApp/project.yml`.
It has to be on everywhere or off everywhere, because it changes symbol
mangling across the package ↔ app link boundary. With it off, a plain
`nonisolated async` function runs on the global concurrent executor instead
of the caller's actor, which was the standard Swift 6.0/6.1 behavior. The two
functions upstream already marks `@concurrent` behave the same either way.

### Deck import

On iOS 17, picking a file in **Import Deck…**, **Import EPUB…** or the
dictionary importer did nothing, and the app wasn't offered for `.apkg` files
elsewhere. The changes:

| Where | Change |
|---|---|
| `AmgiApp/Info.plist` | Declares `net.ankiweb.apkg` / `net.ankiweb.colpkg` (`UTImportedTypeDeclarations`) and registers Amgi as an alternate viewer for them (`CFBundleDocumentTypes`), so iOS recognizes the files and offers **Amgi** in Share / "Open in…" from Safari and Files. Upstream had no document types. |
| `RootFeature/RootView.swift`, `AppShared/DeckImportModifier.swift` | `onOpenURL` now passes file URLs to the deck importer, so "Open in Amgi" imports directly. The copy iOS places in `Documents/Inbox` is deleted afterwards. |
| `AppShared/DeckImportModifier.swift` + new `AppShared/DocumentPicker.swift` | **Import Deck…** now presents a UIKit `UIDocumentPickerViewController` (copy mode) in a sheet, through a new `documentPicker(isPresented:contentTypes:allowsMultipleSelection:onPick:)` modifier, instead of SwiftUI's `.fileImporter`. On iOS 17 the picker opened, but the chosen file never reached the importer that presented it. It allows any file (`.item` instead of `.data`), so downloaded `.apkg`s are never greyed out. The extension check was removed and the Anki engine now rejects files that aren't packages. Error alerts wait for the picker to finish dismissing, because iOS 17 drops an alert presented during that animation. |
| `ReaderFeature/Reader/ReaderLibraryView.swift`, `ReaderDictionarySettingsView.swift` | The same `.fileImporter` problem broke **Import EPUB…** (the file could be selected but was never imported) and the dictionary `.zip` importer. Both now use `documentPicker(...)` with their original file types and multi-select. No SwiftUI `.fileImporter` is left in the iPhone app. |
| `AppShared/ImportHelper.swift` | No longer fails with "Cannot access the selected file" when `startAccessingSecurityScopedResource()` returns `false`. That's normal for non-scoped files and for an unsandboxed TrollStore install. Only a successful call is balanced with `stop…`. |

### Community fixes merged from open upstream PRs

On 2026-10-21 all open upstream issues and PRs were reviewed for anything
that affects studying shared decks on iOS 17. These three open PRs by
[zom-2018](https://github.com/zom-2018) were cherry-picked with `-x`, so each
commit keeps its author and records its original commit. Upstream hasn't
merged them yet. Their own testing was in Apple's simulator, not on a device.

| PR | Fixes | Change |
|---|---|---|
| [#50](https://github.com/antigluten/amgi/pull/50) | [#49](https://github.com/antigluten/amgi/issues/49): swiping to delete a deck could crash the app before you confirmed | The swipe button no longer uses the `.destructive` role, which removed the row early. It keeps its red tint. |
| [#41](https://github.com/antigluten/amgi/pull/41) | [#25](https://github.com/antigluten/amgi/issues/25): learning steps under 1 minute (e.g. 30s) were saved as 0m | Fractional minutes are kept, and `30s` is accepted as input. |
| [#42](https://github.com/antigluten/amgi/pull/42) | [#3](https://github.com/antigluten/amgi/issues/3): card audio and TTS didn't play reliably | `[sound:]` markers are matched case-insensitively. TTS speaks plain text, not HTML. Speech and sound replay in order. Audio stops when the card view closes. |

These use no iOS 18 APIs. Known upstream issues **not** addressed here:
long MathJax cards being cut off ([#52](https://github.com/antigluten/amgi/issues/52),
no fix exists yet), the post-review popup ([#24](https://github.com/antigluten/amgi/issues/24)),
and media *sync* ([#19](https://github.com/antigluten/amgi/issues/19)). Media
inside an imported `.apkg` is unaffected by #19.

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
- The release notes template mentions TrollStore alongside AltStore/Sideloadly
  and says the build needs iOS 17.0+.
- Everything else matches upstream: Xcode 26.3, Rust 1.95, unsigned archive,
  an IPA uploaded as a 7-day artifact, and a GitHub Release with the IPA when a
  `v*` tag is pushed.

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
- **[zom-2018](https://github.com/zom-2018)**, for the deck-delete, learning-step and audio fixes (upstream PRs #50, #41, #42)
- **[Manhhao](https://github.com/Manhhao)**, for [hoshidicts](https://github.com/Manhhao/hoshidicts), the Reader's dictionary engine

iOS 17 port: **Claude** (Anthropic), via Claude Code, for Elementix.
