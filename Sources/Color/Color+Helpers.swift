//
//  Color+Helpers.swift
//  Beige
//
//  Created by PinkXaciD on 2026/06/17.
//

import simd

internal let m2 = simd_double3x3(
    simd_double3(0.2104542553, 0.7936177850, -0.0040720468),
    simd_double3(1.9779984951, -2.4285922050, 0.4505937099),
    simd_double3(0.0259040371, 0.7827717662, -0.8086757660),
)

internal let m2inv = simd_double3x3(
    simd_double3(0.9999999984505198, 0.3963377921737678, 0.21580375806075877),
    simd_double3(1.0000000088817607, -0.10556134232365633, -0.0638541747717059),
    simd_double3(1.0000000546724108, -0.08948418209496575, -1.2914855378640917)
)

internal let lmsToSrgbLinear = simd_double3x3(
    simd_double3(4.077186523210355, -3.307621982185355, 0.2308590687546604),
    simd_double3(-1.2685763405607007, 2.60968684058974, -0.3411556538927156),
    simd_double3(-0.0041964475803312725, -0.7033997379904753, 1.7067959506149537)
)

internal let srgbLinearToLms = simd_double3x3(
    simd_double3(0.41217646006514874, 0.5362739470964155, 0.05144037008198845),
    simd_double3(0.21190919347930934, 0.6807178901449663, 0.10739983171136848),
    simd_double3(0.08834480069237394, 0.2818539796205625, 0.6302808955663188)
)

internal func fromLinear(_ lin: SIMD3<Double>) -> SIMD3<Double> {
    func singleColorFromLinear(_ c: Double) -> Double {
        if c < -0.0031308 {
            return -1.055 * pow(-c, 1 / 2.4) + 0.055
        }
        
        if c > 0.0031308 {
            return 1.055 * pow(c, 1 / 2.4) - 0.055
        }
        
        return 12.92 * c
    }
    
    return SIMD3(
        singleColorFromLinear(lin.x),
        singleColorFromLinear(lin.y),
        singleColorFromLinear(lin.z)
    )
}

internal func toLinear(_ r: Double, _ g: Double, _ b: Double) -> SIMD3<Double> {
    func singleColorToLinear(_ c: Double) -> Double {
        if c < -0.04045 {
            return -pow((-c + 0.055) / 1.055, 2.4)
        }
        
        if c > 0.04045 {
            return pow((c + 0.055) / 1.055, 2.4)
        }
        
        return c / 12.92
    }
    
    return SIMD3(
        singleColorToLinear(r),
        singleColorToLinear(g),
        singleColorToLinear(b)
    )
}
