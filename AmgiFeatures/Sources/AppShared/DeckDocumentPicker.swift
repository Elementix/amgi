//
//  DeckDocumentPicker.swift
//  AppShared
//
//  iOS 17 port. SwiftUI's `.fileImporter` misroutes the picked file when
//  several importers live in one view tree (deck import here, EPUB and
//  dictionary import in the Reader): the picker opens, but the selection
//  never reaches the deck importer. A plain UIKit picker has no such sharing.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DeckDocumentPicker: UIViewControllerRepresentable {
    /// Called with the app's own copy of the picked file (`asCopy: true`),
    /// so no security-scoped access is needed and the caller may delete it.
    let onPick: (URL) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onCancel: onCancel)
    }

    @MainActor
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        let onCancel: () -> Void

        init(onPick: @escaping (URL) -> Void, onCancel: @escaping () -> Void) {
            self.onPick = onPick
            self.onCancel = onCancel
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first { onPick(url) } else { onCancel() }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancel()
        }
    }
}
