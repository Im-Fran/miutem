//
//  HomeView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [.utemAzul, .utemVerde], startPoint: .bottomLeading, endPoint: .topTrailing ))
                    .frame(width: UIScreen.main.bounds.width, height: 100)
                    .ignoresSafeArea()
                    .position(x: UIScreen.main.bounds.width/2, y: 0)
                
                VStack {
                    HStack {
                        VStack {
                            Text("Tiempo sin vernos,\n\(Text("\(authService.perfil?.primerNombre ?? "")").fontWeight(.semibold))")
                                .foregroundColor(.black)
                                .font(.title)
                        }.multilineTextAlignment(.leading)
                        Spacer()
                    }
                    Spacer().frame(height: 50)
                    VStack {
                        HStack {
                            Text("PERMISOS ACTIVOS")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .onTapGesture {
                                    authService.invalidatePermisos()
                                    authService.loadPermisos()
                                }
                            Spacer()
                        }
                        
                        PermisoPreview()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(.lightGrey)
            .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Image(systemName: "line.3.horizontal")
                         .font(.title3)
                         .foregroundColor(.white)
                 }
                 
                 ToolbarItem(placement: .principal) {
                     Text("Inicio")
                         .font(.title2)
                         .fontWeight(.bold)
                         .foregroundColor(.white)
                 }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @StateObject static var authService: AuthService = AuthService()
    static var previews: some View {
        HomeView()
            .environmentObject(authService)
    }
}
