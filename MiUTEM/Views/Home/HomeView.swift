//
//  HomeView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @State var isMenuVisible: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [.utemAzul, .utemVerde], startPoint: .bottomLeading, endPoint: .topTrailing ))
                    .frame(width: UIScreen.main.bounds.width, height: 125)
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
                            Spacer()
                        }
                        
                        PermisoPreview()
                    }
                    
                    Spacer()
                }
                .padding()
                .refreshable {
                    authService.invalidatePermisos()
                    authService.loadPermisos()
                }
                
                
                // MenuView(isMenuVisible: $isMenuVisible).ignoresSafeArea().zIndex(5)
            }
            .background(.lightGrey)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.isMenuVisible.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Inicio")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .gesture(DragGesture(minimumDistance: 5)
                .onEnded {
                    if (($0.location.x - $0.startLocation.x) > 0) {
                        if (!self.isMenuVisible) {
                            withAnimation {
                                self.isMenuVisible.toggle()
                            }
                        }
                    } else {
                        if ($0.translation.width < -100 && self.isMenuVisible) {
                            withAnimation {
                                self.isMenuVisible.toggle()
                            }
                        }
                    }
                }
            )
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
