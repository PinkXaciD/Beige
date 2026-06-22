//
//  Color+OKLAB.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/17.
//

import simd
import SwiftUI

extension Color {
    /// Creates a constant color from lightness, a, and b values.
    /// - Parameters:
    ///   - l: The percieved lightness of a color.
    ///   - a: Describes how much green or red is presented.
    ///   - b: Describes how much yellow or blue is presented.
    public init(lightness l: Double, a: Double, b: Double) {
        let oklab = SIMD3(l, a, b)
        
        let lms_ = oklab * m2inv
        
        let lms = SIMD3(
            pow(lms_.x, 3),
            pow(lms_.y, 3),
            pow(lms_.z, 3),
        )
        
        let linearSRGB = lms * lmsToSrgbLinear // sRGB will be extended (unclamped) to show colors in full Display P3
        
        self.init(.sRGBLinear, red: linearSRGB.x, green: linearSRGB.y, blue: linearSRGB.z)
    }
    
    /// Creates a new `SwiftUI.Color` from the given `OKLAB` color.
    public init(_ oklab: Self.OKLAB) {
        self = oklab.color
    }
}

extension Color {
    /// Creates a new `OKLAB` color from this `SwiftUI.Color`.
    /// - Returns: An `OKLAB` color.
    @MainActor
    public func oklab() -> Self.OKLAB {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        #if canImport(UIKit)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        #elseif canImport(AppKit)
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        #endif
        
        let linearRGB = toLinear(r, g, b)
        
        let lms = linearRGB * srgbLinearToLms
        
        let lms_ = SIMD3(
            cbrt(lms[0]),
            cbrt(lms[1]),
            cbrt(lms[2])
        )
        
        return OKLAB(simd: lms_ * m2)
    }
}

extension Color {
    /// The representation of a color in the `OKLAB` color space.
    public struct OKLAB: OKColor {
        public let l: Double
        public let a: Double
        public let b: Double
        
        /// A `SwiftUI.Color` created from this `OKLAB` color.
        public nonisolated var color: Color {
            Color(lightness: l, a: a, b: b)
        }
        
        /// Creates a new `OKLAB` color from given components.
        /// - Parameters:
        ///   - l: The percieved lightness of a color.
        ///   - a: Describes how much green or red is presented.
        ///   - b: Describes how much yellow or blue is presented.
        public init(lightness l: Double = 0, a: Double = 0, b: Double = 0) {
            self.l = l
            self.a = a
            self.b = b
        }
        
        /// Creates a new `OKLAB` color from the given `SwiftUI.Color`.
        public init(_ color: Color) {
            self = color.oklab()
        }
        
        internal init(simd: SIMD3<Double>) {
            self.l = simd.x
            self.a = simd.y
            self.b = simd.z
        }
        
        /// Creates a new `OKLCH` color from this `OKLAB` color.
        /// - Returns: A new matching instance of `OKLCH`
        public func oklch() -> Color.OKLCH {
            let c = sqrt(pow(a, 2) + pow(b, 2))
            let h = atan2(b, a) / .pi * 180
            
            if h >= 0 {
                return OKLCH(lightness: l, chroma: c, hue: h)
            } else {
                return OKLCH(lightness: l, chroma: c, hue: 360 - abs(h))
            }
        }
        
        internal func getSIMD() -> SIMD3<Double> {
            return .init(x: l, y: a, z: b)
        }
    }
}

extension Color.OKLAB {
    public nonisolated var description: String {
        "Lightness: \(l.formatted(.parameter)), A: \(a.formatted(.parameter)), B: \(b.formatted(.parameter))"
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension Color.OKLAB: ShapeStyle {
    public nonisolated func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        self.color.resolve(in: environment)
    }
}

extension Color.OKLAB {
    public var body: some View {
        self.color
    }
}

public typealias OKLAB = Color.OKLAB
