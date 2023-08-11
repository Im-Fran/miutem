//
//  MiUTEMApp.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI
import Combine

@main
struct MiUTEMApp: App {
    
    @State private var isSplashActive = true
    @State private var isLoggedIn = false
    
    
    var body: some Scene {
        WindowGroup {
            if isSplashActive {
                SplashView(isActive: $isSplashActive)
                    .onAppear {
                        Task {
                            let cached = AuthService.hasCachedPerfil()
                            isLoggedIn = cached
                        }
                    }
            } else if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
            } else {
                HomeView()
            }
        }
    }
}
