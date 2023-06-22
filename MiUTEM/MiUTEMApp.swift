//
//  MiUTEMApp.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI

@main
struct MiUTEMApp: App {
    @State private var isActive = true
    @StateObject var user: User = User()
    
    var body: some Scene {
        WindowGroup {
            if isActive {
                SplashView(isActive: $isActive)
            } else {
                HomeView()
                    .environmentObject(user)
            }
        }
    }
}
