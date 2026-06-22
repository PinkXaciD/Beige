//
//  OKColor.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/17.
//

import SwiftUI

internal protocol OKColor: Hashable, Equatable, Codable, CustomStringConvertible, View {
    init(_ color: SwiftUI.Color)
    
    var color: Color { get }
    
    func getSIMD() -> SIMD3<Double>
    
    @available(iOS 17.0, macOS 14.0, *)
    func resolve(in environment: EnvironmentValues) -> Color.Resolved
}
