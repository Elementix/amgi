//
//  StudyDeckIntent.swift
//  IntentsFeature
//
//  Created by Vladimir Gusev on 19.09.2026.
//

public import AppIntents
import Foundation
#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

/// "Study Korean in Amgi" — opens the app straight into the reviewer.
public struct StudyDeckIntent: AppIntent {
    public init() {}

    public static let title: LocalizedStringResource = "Study Deck"
    public static let description = IntentDescription(
        "Opens Amgi and starts reviewing a deck.",
        categoryName: "Review"
    )
    public static let openAppWhenRun = true

    @Parameter(title: "Deck")
    public var deck: AmgiDeckEntity

    public static var parameterSummary: some ParameterSummary {
        Summary("Study \(\.$deck)")
    }

    public func perform() async throws -> some IntentResult {
        guard let deckId = deck.deckId,
              let url = URL(string: "amgi://review?deckId=\(deckId)")
        else { throw AmgiIntentError.badDeckId }
        // `OpenURLIntent` is iOS 18+. `openAppWhenRun` has already brought
        // the app forward, so it can route its own deep link on iOS 17 too.
        await Self.openInApp(url)
        return .result()
    }

    @MainActor
    private static func openInApp(_ url: URL) async {
        #if canImport(UIKit) && !os(watchOS)
        await UIApplication.shared.open(url)
        #endif
    }
}
