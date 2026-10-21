//
//  CoverZoomTransition.swift
//  ReaderFeature
//

import SwiftUI

/// The cover-to-detail zoom push is iOS 18+. On iOS 17 both modifiers are a
/// no-op and the detail view falls back to the standard push.
extension View {
    @ViewBuilder
    func coverZoomDestination(sourceID: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, macOS 15, *) {
            navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self
        }
    }

    @ViewBuilder
    func coverZoomSource(id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, macOS 15, *) {
            matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }
}
