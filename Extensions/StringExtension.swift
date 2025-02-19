//
//  StringExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/10/14.
//

import Foundation

extension String {
    
    func trim(to maximumCharacters: Int) -> String {
        return "\(self[..<index(startIndex, offsetBy: maximumCharacters)])" + "..."
    }
    
    // Shift-JISに変換できない文字をhtmlの文字参照に切替
    func characterReferenceSJIS() -> String {
        var buf = ""
        for c in self.map({ String($0) }) {
            if c.canBeConverted(to: String.Encoding.shiftJIS) {
                buf.append(c)
            } else {
                let buf1 = NSMutableString(string: c)
                CFStringTransform(buf1, nil, kCFStringTransformToXMLHex, false)
                buf.append(buf1 as String)
            }
        }
        return buf
    }
}
