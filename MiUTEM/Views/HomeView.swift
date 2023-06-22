//
//  HomeView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var user: User
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Text("Iniciar sesión").onTapGesture {
                isLoading.toggle()
                user.attemptLogin {
                    isLoading.toggle()
                }
            }
            
            if(isLoading) {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Text(user.status ?? "Por favor inicia sesión!")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @StateObject static var user: User = User()
    static var previews: some View {
        HomeView()
            .environmentObject(user)
    }
}
