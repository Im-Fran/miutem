//
//  Helpers.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 22-06-23.
//

import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

func generateRandomBytes(length: Int) -> Data? {
    var randomBytes = [UInt8](repeating: 0, count: length)
    
    var status = errSecSuccess
    repeat {
        status = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        if status != errSecSuccess {
            print("Failed to generate random bytes. Status: \(status)")
        }
    } while status != errSecSuccess
    
    return Data(randomBytes)
}
