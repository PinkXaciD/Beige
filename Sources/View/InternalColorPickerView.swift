//
//  InternalColorPickerView.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/22.
//

import SwiftUI

internal struct InternalColorPicker: View {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion
    
    @GestureState
    private var isDragging: Bool = false
    
    @State
    private var value: Double
    @Binding
    private var oklch: OKLCH
    
    private let geometry: GeometryProxy
    
    private let lightness: Double
    private let chroma: Double
    
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint
    
    private let padding: CGFloat
    private let size: CGFloat
    private let strokeThickness: CGFloat
    private let cornerRadius: CGFloat
    private let overlayCornerRadius: CGFloat
    
    private let enableHaptics: Bool
    private let hideHandle: Bool
    
    private var height: CGFloat {
        if isDragging || !hideHandle {
            return size
        }
        
        let constantHeight = geometry.size.height - cornerRadius * 2
        
        if offset <= cornerRadius {
            let r = pow(cornerRadius, 2)
            let d = pow((cornerRadius - offset), 2)
            return 2 * sqrt(r - d) - (padding) * 2 + constantHeight
        } else if offset >= (geometry.size.width - cornerRadius) {
            let trailingRadius = geometry.size.width - geometry.size.height + constantHeight
            let hangingOffset = (offset + padding) - trailingRadius
            
            let r = pow(cornerRadius, 2)
            let d = pow((cornerRadius - hangingOffset), 2)
            return 2 * sqrt(r - d) - (padding) * 2 + constantHeight
        }
        
        return size
    }
    
    private var width: CGFloat {
        if isDragging || !hideHandle {
            return size
        }
        
        return 2
    }
    
    private var offset: CGFloat {
        let adjWidth = geometry.size.width - padding * 2
        var xOffset = adjWidth * (oklch.h / 360)
        
        if isDragging || !hideHandle {
            xOffset -= size * 0.5
            return xOffset.clamp(padding, geometry.size.width - size - padding)
        } else {
            return xOffset.clamp(padding, adjWidth)
        }
    }
    
    private var offsetAnimation: Animation? {
        if isDragging || reduceMotion {
            return nil
        }
        
        return .interactiveSpring
    }
    
    init(
        oklch: Binding<Color.OKLCH>,
        geometry: GeometryProxy,
        lightness: Double,
        chroma: Double,
        enableHaptics: Bool,
        hideHandle: Bool,
        cornerRadius: CGFloat?
    ) {
        self._value = State(initialValue: oklch.wrappedValue.h)
        self._oklch = oklch
        self.geometry = geometry
        self.lightness = lightness
        self.chroma = chroma
        
        let padding: CGFloat = 3
        let defaultCornerRadius = geometry.size.height * 0.5
        
        self.startPoint = UnitPoint(x: (geometry.size.height / (geometry.size.height - padding * 0.5)) - 1, y: 0)
        self.endPoint = UnitPoint(x: 1 - startPoint.x, y: 0)
        
        self.padding = padding
        self.size = geometry.size.height - padding * 2
        self.strokeThickness = min(3, geometry.size.height * 0.075)
        self.cornerRadius = cornerRadius ?? defaultCornerRadius
        self.overlayCornerRadius = (cornerRadius ?? defaultCornerRadius) - padding
        
        self.enableHaptics = enableHaptics
        self.hideHandle = hideHandle
    }
    
    var body: some View {
        LinearGradient(
            colors: .getOklchGradient(lightness: lightness, chroma: chroma),
            startPoint: startPoint,
            endPoint: endPoint
        )
        .accessibilityIgnoresInvertColors()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .animation(.default, value: isDragging)
        .gesture(gesture(geometry.size.width, padding: padding))
        .overlay(alignment: .leading) {
            overlayView
        }
    }
    
    private var overlayView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: overlayCornerRadius)
                .fill(.white)
                .shadow(color: .init(white: 0, opacity: 0.2), radius: 5)
            
            RoundedRectangle(cornerRadius: overlayCornerRadius - strokeThickness)
                .fill(oklch.color)
                .accessibilityIgnoresInvertColors()
                .padding((isDragging || !hideHandle) ? strokeThickness : 1)
        }
        .compositingGroup()
        .frame(width: width, height: height)
        .animation(reduceMotion ? nil : .spring.speed(2), value: isDragging)
        .offset(x: offset)
        .animation(offsetAnimation, value: offset)
    }
    
    private func gesture(_ width: CGFloat, padding: CGFloat = 0) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .updating($isDragging) { value, state, _ in
                if !state, abs(value.translation.width) > 0 {
                    state = true
                }
                
                let adjustedWidth = width - padding * 2
                let gestureLocation = (value.location.x - padding).clamp(0, adjustedWidth)
                let positionValue = gestureLocation / adjustedWidth
                
                guard positionValue != self.value else {
                    return
                }
                
                if enableHaptics, positionValue == 0 || positionValue == 1 {
                    let maxVelocityValue = adjustedWidth / 2
                    let velocityValue = min(abs(value.velocity.width), maxVelocityValue)
                    let velocityCoefficient = Float(velocityValue / maxVelocityValue)
                    
                    CustomHapticManager.shared.playFeedback(intensity: 0.5 * velocityCoefficient, sharpness: 0.55)
                }
                
                Task { @MainActor in
                    self.value = positionValue
                    self.oklch = OKLCH(l: lightness, c: chroma, v: positionValue)
                }
            }
    }
}
