//
//  HomeView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI
import Shimmer
import Combine

struct HomeView: View {
    @State var perfil: Perfil?
    
    @State var isMenuVisible: Bool = false
    @State var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [.utemAzul, .utemVerde], startPoint: .bottomLeading, endPoint: .topTrailing ))
                    .frame(width: UIScreen.main.bounds.width, height: 125)
                    .ignoresSafeArea()
                    .position(x: UIScreen.main.bounds.width/2, y: 0)
                    .zIndex(0)
                
                VStack {
                    HStack {
                        VStack(alignment: .leading){
                            Text("Tiempo sin vernos,")
                                .foregroundColor(.black)
                                .font(.title)
                            if isLoading {
                                Text("Usuario")
                                    .foregroundColor(.black)
                                    .font(.title)
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                            } else {
                                Text(perfil?.primerNombre ?? "")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .font(.title)
                            }
                        }
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
                
                
                MenuView(isMenuVisible: $isMenuVisible)
                    .ignoresSafeArea()
                    .zIndex(1)
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
            
            .onAppear {
                if isLoading {
                    Task {
                        do {
                            let perfil = try await AuthService.getPerfil()
                            self.perfil = perfil
                            isLoading = false
                        } catch {
                            print(error.localizedDescription)
                            // Handle error
                        }
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
