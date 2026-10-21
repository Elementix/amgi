//
//  AmgiTag.swift
//  Theme
//

public import SwiftUI

public extension View {
    /// Drop-in replacement for `.tag(_:)` that also works on iOS 17.
    ///
    /// Built with the iOS 18+ SDK, `.tag(_:)` writes its trait through
    /// `_TagTraitWritingModifier`, a type that iOS 17's SwiftUI doesn't
    /// export. Any view whose static type contains it segfaults on iOS 17
    /// as soon as SwiftUI inspects its layout. `ForEach` tags each element
    /// with its `id` inside the framework, using the running OS's own
    /// mechanism, so a one-element `ForEach` gives the same result.
    ///
    /// Tags with both `V` and `V?`, matching `.tag(_:includeOptional: true)`,
    /// so pickers bound to an optional selection keep matching.
    func amgiTag<V: Hashable>(_ value: V) -> some View {
        ForEach([Optional(value)], id: \.self) { _ in
            ForEach([value], id: \.self) { _ in self }
        }
    }
}
