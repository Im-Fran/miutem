//
//  MiUTEMApp.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI

@main
struct MiUTEMApp: App {
    @StateObject private var appService = AppService()
    
    @State private var isSplashActive = true
    
    var body: some Scene {
        WindowGroup {
            if isSplashActive {
                SplashView(isActive: $isSplashActive)
            } else if (!appService.authService.hasCachedPerfil()) {
                LoginView()
                    .environmentObject(appService)
            } else {
                HomeView()
                    .environmentObject(appService)
            }
        }
    }
}
