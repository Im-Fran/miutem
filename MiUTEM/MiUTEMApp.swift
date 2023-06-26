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
    @StateObject var authService: AuthService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            if isActive {
                SplashView(isActive: $isActive)
                    .onAppear {
                        authService.attemptLogin {}
                    }
            } else if (authService.status != "ok") {
                LoginView()
                    .environmentObject(authService)
            } else {
                HomeView()
                    .environmentObject(authService)
            }
        }
    }
}
