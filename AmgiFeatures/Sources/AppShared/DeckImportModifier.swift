//
//  DeckImportModifier.swift
//  AppShared
//
//  Created by Vladimir Gusev on 13.06.2026.
//

public import SwiftUI
import Foundation
import Theme
import UniformTypeIdentifiers

private struct DeckImportModifier: ViewModifier {
    @Binding var isPresented: Bool
    /// A package handed to the app from outside (Files / Safari "Open in…").
    @Binding var openedFile: URL?
    let onRefresh: () -> Void

    @State private var status: ImportStatusBanner.Status?
    @State private var failure: String?

    func body(content: Content) -> some View {
        content
            // A UIKit picker rather than `.fileImporter` (see DocumentPicker).
            // It allows any file (`.item`) so a downloaded `.apkg` is never
            // greyed out; the backend rejects anything that isn't a package.
            .documentPicker(isPresented: $isPresented, contentTypes: [.item]) { urls in
                handleImport(.success(urls[0]), removeAfterwards: true)
            }
            .onChange(of: openedFile) { _, url in
                guard let url else { return }
                openedFile = nil
                handleImport(.success(url), removeAfterwards: true)
            }
            .overlay(alignment: .top) { ImportStatusBanner(status: status) }
            .animation(AmgiMotion.momentum, value: status)
            .alert(
                "Couldn't import deck",
                isPresented: Binding(get: { failure != nil }, set: { if !$0 { failure = nil } }),
                presenting: failure
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
    }

}

private extension DeckImportModifier {
    /// `removeAfterwards` deletes the source once read: "Open in…" hands the
    /// app its own copy in `Documents/Inbox`, which would otherwise pile up.
    func handleImport(_ result: Result<URL, any Error>, removeAfterwards: Bool = false) {
        switch result {
        case .success(let url):
            Task {
                defer { if removeAfterwards { try? FileManager.default.removeItem(at: url) } }
                status = .importing(fileName: url.lastPathComponent)
                do {
                    let summary = try await ImportHelper.importPackage(from: url)
                    onRefresh()
                    status = .finished(summary: summary)
                    try? await Task.sleep(for: .seconds(3))
                    status = nil
                } catch {
                    status = nil
                    await showFailure(error.localizedDescription)
                }
            }
        case .failure(let error):
            Task { await showFailure("Could not select file: \(error.localizedDescription)") }
        }
    }

    /// Waits out the document picker's dismissal first: on iOS 17 an alert
    /// presented while the picker is still animating away is dropped.
    func showFailure(_ message: String) async {
        try? await Task.sleep(for: .milliseconds(600))
        failure = message
    }
}

extension View {
    public func deckImport(
        isPresented: Binding<Bool>,
        openedFile: Binding<URL?> = .constant(nil),
        onRefresh: @escaping () -> Void
    ) -> some View {
        modifier(DeckImportModifier(isPresented: isPresented, openedFile: openedFile, onRefresh: onRefresh))
    }
}
