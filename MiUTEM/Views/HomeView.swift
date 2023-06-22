//
//  HomeView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        VStack {
            Text("Hello, \(user.getString(key: "nombreCompleto"))!")
            Button("Cerrar Sesión") {
                user.logout()
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
