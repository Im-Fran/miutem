//
//  PermisoPreview.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 25-06-23.
//

import SwiftUI
import ActivityIndicatorView
import Shimmer

struct PermisoPreview: View {
    @EnvironmentObject var authService: AuthService
    
    @State var isLoading: Bool = true
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                if isLoading {
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
                    ForEach(authService.permisosSimples, id: \.self) { permiso in
                        NavigationLink(destination: PermisoDetail(permisoSimple: permiso)) {
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
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + ([1,1.1,1.2,1.3,1.4,1.5].randomElement() ?? 1)) {
                    authService.loadPermisos {
                        if (!authService.permisosSimples.isEmpty) {
                            isLoading.toggle()
                        }
                    }
                }
            }
        }
        
    }
}


struct PermisoPreview_Previews: PreviewProvider {
    
    @StateObject static var authService: AuthService = AuthService()
    
    static var previews: some View {
        PermisoPreview()
            .environmentObject(authService)
    }
}

