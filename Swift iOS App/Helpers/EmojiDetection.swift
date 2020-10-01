//
//  EmojiDetection.swift
//  sporthealth
//
//  Created by Alex Borchers on 24.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties else {
            return false
        }
        return unicodeScalars.count == 1 &&
            (firstProperties.isEmojiPresentation || firstProperties.generalCategory == .otherSymbol)
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        (unicodeScalars.count > 1 &&
               unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector })
            || unicodeScalars.allSatisfy({ $0.properties.isEmojiPresentation })
    }

    var isEmoji: Bool {
        isSimpleEmoji || isCombinedIntoEmoji
    }
}

extension String {
    var isSingleEmoji: Bool {
        count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        !isEmpty && !contains { !$0.isEmoji }
    }

    var emojiString: String {
        emojis.map { String($0) }.reduce("", +)
    }

    var emojis: [Character] {
        filter { $0.isEmoji }
    }

    var emojiScalars: [UnicodeScalar] {
        filter { $0.isEmoji }.flatMap { $0.unicodeScalars }
    }
}
