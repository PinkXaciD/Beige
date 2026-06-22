//
//  HapticManager.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/17.
//

import CoreHaptics
#if DEBUG
import OSLog
#endif

final internal class CustomHapticManager {
    private let engine: CHHapticEngine?
    private let sharpnessParameter: CHHapticEventParameter
    
    @MainActor
    internal static let shared: CustomHapticManager = CustomHapticManager() // Singleton
    
#if DEBUG
    private let logger = Logger(subsystem: "com.pinkxacid.beidge", category: "Haptics")
#endif
    
    internal init() {
        self.sharpnessParameter = .init(parameterID: .hapticSharpness, value: 0.55)
        
        do {
            self.engine = try CHHapticEngine()
        } catch {
            self.engine = nil
#if DEBUG
            logger.error("Failed to create the engine: \(error.localizedDescription).")
#endif
            return
        }
        
        if self.engine == nil {
#if DEBUG
            logger.warning("No engine was previously created.")
#endif
            return
        }
        
        do {
            try self.engine?.start()
        } catch {
#if DEBUG
            logger.error("Failed to start the engine: \(error.localizedDescription).")
#endif
        }
    }
    
    internal func playFeedback(intensity intensityValue: Float = 1, sharpness sharpnessValue: Float = 1) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        guard let engine else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensityValue)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpnessParameter], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
#if DEBUG
            logger.error("Failed to play pattern: \(error.localizedDescription).")
#endif
        }
    }
}
