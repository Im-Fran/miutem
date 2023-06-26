//
//  HomeView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var user: User
    
    private let gradient = LinearGradient(
        colors: [.utemAzul, .utemVerde],
        startPoint: .bottomLeading,
        endPoint: .topTrailing
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(gradient)
                    .frame(width: .infinity, height: 100)
                    .ignoresSafeArea()
                    .position(x: UIScreen.main.bounds.width/2, y: 0)
                
                VStack {
                    HStack {
                        VStack {
                            Text("Tiempo sin vernos,\n\(Text("\(user.perfil?.primerNombre ?? "")").fontWeight(.semibold))")
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
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                PermisoPreview()
                            }
                        }
                        
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
    @StateObject static var user: User = User()
    static var previews: some View {
        HomeView()
            .environmentObject(user)
    }
}
