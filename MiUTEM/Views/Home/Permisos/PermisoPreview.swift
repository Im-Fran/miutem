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
                                    .frame(width: 48, height: 48)
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
                        }
                        .frame(width: UIScreen.main.bounds.width * (3/4), height: 175)
                        .background(.white)
                        .cornerRadius(15)
                    }.onAppear {
                        authService.loadPermisos {
                            if (!authService.permisos.isEmpty) {
                                isLoading.toggle()
                            }
                        }
                    }
                } else {
                    ForEach(0..<authService.permisos.count, id: \.self) { i in
                        let permiso = authService.permisos[i]
                        NavigationLink(destination: PermisoDetail(permiso: permiso)) {
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
                                        Text(permiso.tipo)
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

