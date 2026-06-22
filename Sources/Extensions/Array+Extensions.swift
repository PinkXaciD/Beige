//
//  Array+Extensions.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/17.
//

import SwiftUI

extension Array<Color> {
    internal static func getOklchGradient(lightness l: Double, chroma c: Double) -> Self {
        stride(from: 0, to: 1, by: 0.005).map { value in
            Color(l: l, c: c, v: value)
        }
    }
}
