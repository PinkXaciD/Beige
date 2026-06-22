//
//  Color+OKLCH.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/17.
//

import SwiftUI

extension Color {
    /// Creates a constant color from lightness, chroma, and hue component values.
    /// - Parameters:
    ///   - l: The percieved lightness of a color.
    ///   - c: The chroma (saturation) of a color.
    ///   - h: The hue value in degrees between 0 and 360.
    public init(lightness l: Double, chroma c: Double, hue h: Double) {
        let hueRad = (h * .pi) / 180
        
        self.init(lightness: l, a: c * cos(hueRad), b: c * sin(hueRad))
    }
    
    /// Creates a new `SwiftUI.Color` from the given `OKLCH` color.
    public init(_ oklch: Self.OKLCH) {
        self = oklch.color
    }
    
    internal init(l: Double, c: Double, v: Double) {
        let hueRad = v * .pi * 2
        
        self.init(lightness: l, a: c * cos(hueRad), b: c * sin(hueRad))
    }
}

extension Color {
    /// Creates a new `OKLCH` color from this `SwiftUI.Color`.
    /// - Returns: An `OKLCH` color.
    @MainActor public func oklch() -> Self.OKLCH {
        return self.oklab().oklch()
    }
}

extension Color {
    /// The representation of a color in the `OKLCH` color space.
    public struct OKLCH: OKColor {
        public let l: Double
        public let c: Double
        public let h: Double
        
        /// A `SwiftUI.Color` created from this `OKLCH` color.
        public nonisolated var color: Color {
            Color(lightness: l, chroma: c, hue: h)
        }
        
        /// Creates a new `OKLCH` color from given components.
        /// - Parameters:
        ///   - l: The percieved lightness of a color.
        ///   - c: The chroma (saturation) of a color.
        ///   - h: The hue value in degrees between 0 and 360.
        public init(lightness l: Double = 0, chroma c: Double = 0, hue h: Double = 0) {
            self.l = l
            self.c = c
            self.h = h
        }
        
        /// Creates a new `OKLCH` color from the given `SwiftUI.Color`.
        public init(_ color: Color) {
            self = color.oklch()
        }
        
        internal init(l: Double = 0, c: Double = 0, v: Double = 0) {
            self.l = l
            self.c = c
            self.h = 360 * v
        }
        
        internal init(simd: SIMD3<Double>) {
            self.l = simd.x
            self.c = simd.y
            self.h = simd.z
        }
        
        /// Creates a new `OKLAB` color from this `OKLCH` color.
        /// - Returns: A new matching instance of `OKLAB`
        public func oklab() -> Color.OKLAB {
            let hueRad = (h * .pi) / 180
            
            return Color.OKLAB(lightness: l, a: c * cos(hueRad), b: c * sin(hueRad))
        }
        
        /// Shifts `OKLCH` parameters by a given amount.
        /// - Parameters:
        ///   - l: Lightness shift amount.
        ///   - c: Chroma shift amount.
        ///   - h: Hue shift amount.
        /// - Returns: A new OKLCH color with updated values.
        public func shift(lightness l: Double = 0, chroma c: Double = 0, hue h: Double = 0) -> Self {
            return .init(lightness: self.l + l, chroma: self.c + c, hue: self.h + h)
        }
        
        internal func getSIMD() -> SIMD3<Double> {
            .init(x: l, y: c, z: h)
        }
    }
}

extension Color.OKLCH {
    public nonisolated var description: String {
        "Lightness: \(l.formatted(.parameter)), Chroma: \(c.formatted(.parameter)), Hue: \(h.formatted(.parameter))"
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension Color.OKLCH: ShapeStyle {
    public nonisolated func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        self.color.resolve(in: environment)
    }
}

extension Color.OKLCH {
    public var body: some View {
        self.color
    }
}

public typealias OKLCH = Color.OKLCH
