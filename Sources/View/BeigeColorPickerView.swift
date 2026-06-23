//
//  BeigeColorPickerView.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/17.
//

import SwiftUI

public struct BeigeColorPicker: View {
    @Binding private var oklch: OKLCH
    
    private let lightness: Double
    private let chroma: Double
    private let enableHaptics: Bool
    private let hideHandle: Bool
    private let cornerRadius: CGFloat?
    
    public init(
        color oklch: Binding<OKLCH>,
        enableHaptics: Bool = true,
        hideHandle: Bool = true,
        cornerRadius: CGFloat? = nil
    ) {
        self._oklch = oklch
        
        self.lightness = oklch.wrappedValue.l
        self.chroma = oklch.wrappedValue.c
        self.enableHaptics = enableHaptics
        self.hideHandle = hideHandle
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        GeometryReader { geometry in
            InternalColorPicker(
                oklch: $oklch,
                geometry: geometry,
                lightness: lightness,
                chroma: chroma,
                enableHaptics: enableHaptics,
                hideHandle: hideHandle,
                cornerRadius: cornerRadius
            )
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}
