//
//  TagHelper.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/12.
//

import Foundation
import Emoji

struct TagHelper {
    static func pickupTags(text: String) -> Set<String> {
        let formated = text.components(separatedBy: "#")
            .map { $0.emojiEscapedString }
            .joined(separator: "#")
        var tags: [String] = []
        do {
            let range = NSRange(location: 0, length: formated.utf16.count)
            let regix = try NSRegularExpression(pattern: "#[^#\\s]*", options: .anchorsMatchLines)
            let matcher = regix.matches(in: formated, options: .withTransparentBounds, range: range)
            if matcher.isEmpty { return [] }
            matcher.forEach { result in
                for i in 0..<result.numberOfRanges {
                    let start = formated.index(formated.startIndex, offsetBy: result.range(at: i).location)
                    let length = result.range(at: i).length
                    let end = formated.index(start, offsetBy: length, limitedBy: formated.endIndex) ?? formated.endIndex
                    tags.append(String(formated[start..<end]).trimmingCharacters(in: .whitespaces).emojiUnescapedString)
                }
            }
        } catch {
            print("\(error.message)")
        }
        return Set(tags)
    }
}
