//
//  ArrayExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/20.
//

import Foundation

extension Array {
    func split(num: Int) -> [[Element]] {
        let count = self.count
        if count <= num {
            return [self]
        }
        if count <= num * 2 {
            return [Array<Element>(self[0..<num])] + [Array<Element>(self[num...])]
        }
        let splitPoint = Int(count / num / 2) * num
        switch splitPoint {
        case num:
            return [Array<Element>(self[0..<num])]
                + Array<Element>(self[num..<count]).split(num: num)
            
        case (num...):
            return Array<Element>(self[0..<splitPoint]).split(num: num)
                + Array<Element>(self[splitPoint..<count]).split(num: num)
            
        default:
            return [self]
        }
    }
}
