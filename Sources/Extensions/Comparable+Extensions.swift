//
//  Comparable+Extensions.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/17.
//

import Foundation

extension Comparable {
    internal func clamp(_ minValue: Self, _ maxValue: Self) -> Self {
        return min(max(self, minValue), maxValue)
    }
}
