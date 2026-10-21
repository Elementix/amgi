//
//  MainTabView.swift
//  RootFeature
//
//  Created by Vladimir Gusev on 27.03.2026.
//

import AppCore
import AnkiKit
import DecksFeature
import ReaderFeature
import SettingsFeature
import StatsFeature
import SwiftUI
import SyncFeature
import Theme

/// Root tab bar. Pure layout: each tab wraps a feature view in a
/// `NavigationStack`. `refreshID` (bumped by the host after sync / import /
/// review) now only drives the tabs not yet on `CollectionStore` — Library
/// and Study reload via the store's generation instead. All side effects are
/// forwarded to the host via closures or `\.startSync` so this view owns no
/// I/O or sync state.
///
/// `refreshID` is *handed to* the two tabs that reload from it, not applied as
/// an `.id()`. As an `.id()` it discarded each tab's whole subtree — scroll
/// position, search text, selected deck, pushed navigation — to trigger a
/// reload their own `.task` already performs. Settings took the teardown and
/// got nothing for it: its root has no data load at all.
struct MainTabView: View {
    let refreshID: UUID
    let showReaderTab: Bool
    let onImport: () -> Void
    let onSelectStudyDeck: (DeckID) -> Void

    @Environment(\.startSync) private var startSync

    private enum MainTab: Hashable {
        case library, read, study, stats, settings
    }

    @State private var selection: MainTab = .library

    var body: some View {
        tabs
        .background {
            Button("Settings") { selection = .settings }
                .keyboardShortcut(",", modifiers: .command)
                .opacity(0)
                .accessibilityHidden(true)
        }
    }

    /// The `Tab` builder is iOS 18+; iOS 17 gets the same tabs through
    /// `.tabItem` + `.tag`.
    @ViewBuilder
    private var tabs: some View {
        if #available(iOS 18, macOS 15, *) {
            TabView(selection: $selection) {
                // 1. Library
                Tab("Library", systemImage: "rectangle.stack", value: MainTab.library) {
                    libraryTab
                }
                // 2. Reader and 3. Study both live in ReaderFeature.
                if showReaderTab {
                    Tab("Read", systemImage: "book", value: MainTab.read) {
                        readTab
                    }
                }
                Tab("Study", systemImage: "graduationcap", value: MainTab.study) {
                    studyTab
                }
                // 4. Stats
                Tab("Stats", systemImage: "chart.bar", value: MainTab.stats) {
                    statsTab
                }
                // 5. Settings
                Tab("Settings", systemImage: "gearshape", value: MainTab.settings) {
                    settingsTab
                }
            }
        } else {
            TabView(selection: $selection) {
                libraryTab
                    .tabItem { Label("Library", systemImage: "rectangle.stack") }
                    .amgiTag(MainTab.library)
                if showReaderTab {
                    readTab
                        .tabItem { Label("Read", systemImage: "book") }
                        .amgiTag(MainTab.read)
                }
                studyTab
                    .tabItem { Label("Study", systemImage: "graduationcap") }
                    .amgiTag(MainTab.study)
                statsTab
                    .tabItem { Label("Stats", systemImage: "chart.bar") }
                    .amgiTag(MainTab.stats)
                settingsTab
                    .tabItem { Label("Settings", systemImage: "gearshape") }
                    .amgiTag(MainTab.settings)
            }
        }
    }

    private var libraryTab: some View {
        NavigationStack {
            DeckListView(
                onSwitchProfile: { await switchProfile(to: $0) },
                onSync: { startSync() },
                onImport: onImport
            )
        }
    }

    private var readTab: some View {
        NavigationStack {
            ReaderLibraryView(refreshID: refreshID)
        }
    }

    private var studyTab: some View {
        NavigationStack {
            StudyLandingView(onSelectDeck: onSelectStudyDeck)
        }
    }

    private var statsTab: some View {
        NavigationStack {
            StatsDashboardView(refreshID: refreshID)
        }
    }

    private var settingsTab: some View {
        NavigationStack {
            SettingsView(onSwitchProfile: { await switchProfile(to: $0) })
        }
    }
}
