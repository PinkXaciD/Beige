//
//  FormatStyle+Extensions.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/22.
//

import SwiftUI

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    static internal var parameter: Self {
        Self.number.precision(.fractionLength(0...3))
    }
}
