//
//  PermisoDetail.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 26-06-23.
//

import SwiftUI
import Shimmer

struct PermisoDetail: View {
    
    var permisoSimple: PermisoSimple
    @State var permiso: Permiso? = nil
    @State var qrImage: UIImage? = nil
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.utemAzul, .utemVerde], startPoint: .bottomLeading, endPoint: .topTrailing ))
                .frame(width: UIScreen.main.bounds.width, height: 100)
                .ignoresSafeArea()
                .position(x: UIScreen.main.bounds.width/2, y: 0)
             
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .padding()
                        
                        VStack(alignment: .leading){
                            Text("\(authService.perfil?.nombres.capitalized ?? "")")
                                .foregroundColor(.black)
                            Text("\(authService.perfil?.apellidos.capitalized ?? "")")
                                .foregroundColor(.black)
                            
                            Text("\(authService.perfil?.rutCompleto.uppercased() ?? "")")
                                .foregroundColor(.grey)
                                .font(.footnote)
                        }
                        Spacer()
                    }.padding()
                    Divider()
                    VStack(alignment: .leading){
                        HStack {
                            VStack(alignment: .leading){
                                Text("MOTIVO")
                                    .foregroundColor(.grey)
                                    .fontWeight(.bold)
                                    .font(.callout)
                                Text(permisoSimple.motivo)
                                    .foregroundColor(.grey)
                                    .fontWeight(.light)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                            }
                            Spacer()
                        }
                        .padding()
                    
                        HStack {
                            VStack(alignment: .leading){
                                Text("JORNADA")
                                    .foregroundColor(.grey)
                                    .fontWeight(.bold)
                                    .font(.callout)
                                Text(permisoSimple.jornada)
                                    .foregroundColor(.grey)
                                    .fontWeight(.light)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                            }
                            Spacer()
                            VStack(alignment: .leading){
                                Text("VIGENCIA")
                                    .foregroundColor(.grey)
                                    .fontWeight(.bold)
                                    .font(.callout)
                                if(permiso == nil) {
                                    Text("Desconocida")
                                        .foregroundColor(.grey)
                                        .fontWeight(.light)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                } else {
                                    Text(permiso?.vigencia ?? "Desconocida")
                                        .foregroundColor(.grey)
                                        .fontWeight(.light)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .padding()
                    Divider()
                    VStack(alignment: .center){
                        if qrImage == nil {
                            Image(systemName: "qrcode")
                                .resizable()
                                .frame(width: 128, height: 128)
                                .padding(.vertical, 15)
                                .redacted(reason: .placeholder)
                                .shimmering()
                        } else {
                            Image(uiImage: qrImage!)
                                .resizable()
                                .frame(width: 128, height: 128)
                                .padding(.vertical, 15)
                        }
                        
                        Text("Permiso generado el \(permisoSimple.fechaSolicitud.replacing("-", with: "/").replacing("T00:00:00.000Z", with: ""))")
                            .foregroundColor(.grey)
                            .font(.footnote)
                            .padding(.bottom, 20.0)
                    }.padding()
                }
                .frame(width: UIScreen.main.bounds.width * 0.8)
                .background(.white)
                .cornerRadius(15)
                
                Spacer()
            } 
            .padding()
        }
        .background(.lightGrey)
        .navigationBarBackButtonHidden(true)
        .toolbar {
             ToolbarItem(placement: .navigationBarLeading) {
                 Button(action: {
                     presentationMode.wrappedValue.dismiss()
                 }) {
                     Image(systemName: "chevron.left")
                         .font(.title3)
                         .foregroundColor(.white)
                 }
             }
             
             ToolbarItem(placement: .principal) {
                 Text("Permiso de Ingreso")
                     .font(.title2)
                     .fontWeight(.bold)
                     .foregroundColor(.white)
             }
        }
        .gesture(DragGesture().onEnded { gesture in
            if gesture.translation.width > 100 {
                presentationMode.wrappedValue.dismiss()
            }
        })
        .onAppear {
            // Carga detalle del permiso
            DispatchQueue.global(qos: .userInitiated).async {
                let permiso = PermisoService.getDetalle(permisoSimple: permisoSimple, credentials: authService.getStoredCredentials())
                if(permiso != nil) {
                    let qrImage = QRGeneratorService.qrCode(text: permiso?.codigoQr ?? "", size: .init(width: 128, height: 128))
                    if(qrImage != nil) {
                        DispatchQueue.main.async {
                            self.permiso = permiso
                            self.qrImage = qrImage
                        }
                    }
                }
            }
        }
    }
}
