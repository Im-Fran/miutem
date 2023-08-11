//
//  PermisoPreview.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 25-06-23.
//

import SwiftUI
import ActivityIndicatorView
import Shimmer
import Combine

struct PermisoPreview: View {
    @State var perfil: Perfil?
    @State var permisosSimples: [PermisoSimple] = []
    
    @State var isLoading: Bool = true
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                if isLoading || perfil == nil {
                    ZStack {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "qrcode")
                                    .resizable()
                                    .frame(width: 54, height: 54)
                                VStack {
                                    Text("Estudiante")
                                        .font(.body)
                                        .foregroundColor(.mediumGrey)
                                        .lineLimit(nil)
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                    Text("Permiso académico de ingreso a clases")
                                        .foregroundColor(.brand)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                }
                                Spacer()
                            }
                            .padding()
                            
                            Spacer()
                            Divider()
                            Text("Ver QR")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                        }
                        .frame(width: UIScreen.main.bounds.width * (3/4), height: 200)
                        .background(.white)
                        .cornerRadius(15)
                    }
                } else {
                    ForEach(permisosSimples, id: \.self) { permiso in
                        NavigationLink(destination: PermisoDetail(perfil: perfil!, permisoSimple: permiso)) {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack {
                                        Image(systemName: "qrcode")
                                            .resizable()
                                            .frame(width: 54, height: 54)
                                    }
                                    VStack(alignment: .leading){
                                        Text(permiso.perfil)
                                            .font(.body)
                                            .foregroundColor(.mediumGrey)
                                        Text(permiso.motivo)
                                            .foregroundColor(.brand)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                    }
                                    Spacer()
                                }
                                .padding()
                                
                                Spacer()
                                Divider()
                                Text("Ver QR")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 10)
                            }
                            .frame(width: UIScreen.main.bounds.width * (3/4), height: 200)
                            .background(.white)
                            .cornerRadius(15)
                        }
                        .foregroundColor(.black)
                    }
                }
            }.onAppear {
                if isLoading {
                    // Carga perfil
                    Task {
                        do {
                            let perfil = try? await AuthService.getPerfil()
                            self.perfil = perfil
                            
                            let permisos = try await PermisosService.getPermisosSimples()
                            self.permisosSimples = permisos
                            
                            if !self.permisosSimples.isEmpty {
                                isLoading = false
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
    }
}

