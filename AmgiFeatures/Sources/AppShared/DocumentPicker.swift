//
//  DocumentPicker.swift
//  AppShared
//
//  iOS 17 port. SwiftUI's `.fileImporter` misroutes the picked file when
//  several importers live in one view tree (deck import, EPUB import and
//  dictionary import): the picker opens, but the selection never reaches the
//  importer that presented it. A plain UIKit picker has no such sharing, so
//  every importer in the app uses `documentPicker(...)` instead.
//

public import SwiftUI
import UIKit
public import UniformTypeIdentifiers

extension View {
    /// Drop-in replacement for `.fileImporter(isPresented:allowedContentTypes:
    /// allowsMultipleSelection:)` backed by `UIDocumentPickerViewController`.
    /// `onPick` receives the app's own copies of the files (`asCopy: true`),
    /// so no security-scoped access is needed and they may be deleted.
    public func documentPicker(
        isPresented: Binding<Bool>,
        contentTypes: [UTType],
        allowsMultipleSelection: Bool = false,
        onPick: @escaping ([URL]) -> Void
    ) -> some View {
        sheet(isPresented: isPresented) {
            DocumentPicker(
                contentTypes: contentTypes,
                allowsMultipleSelection: allowsMultipleSelection,
                onPick: { urls in
                    isPresented.wrappedValue = false
                    if !urls.isEmpty { onPick(urls) }
                },
                onCancel: { isPresented.wrappedValue = false }
            )
            .ignoresSafeArea()
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let allowsMultipleSelection: Bool
    let onPick: ([URL]) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onCancel: onCancel)
    }

    @MainActor
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: ([URL]) -> Void
        let onCancel: () -> Void

        init(onPick: @escaping ([URL]) -> Void, onCancel: @escaping () -> Void) {
            self.onPick = onPick
            self.onCancel = onCancel
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onPick(urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancel()
        }
    }
}
