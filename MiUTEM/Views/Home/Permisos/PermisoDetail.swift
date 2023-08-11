//
//  PermisoDetail.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 26-06-23.
//

import SwiftUI
import Shimmer
import Combine

struct PermisoDetail: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var perfil: Perfil
    @State var permisoSimple: PermisoSimple
    
    @State var permiso: Permiso? = nil
    @State var qrImage: UIImage? = nil
    
    @State var error: String? = nil
    @State var showErrorToast: Bool = false
    
    
    var body: some View {
        ZStack {
             Rectangle()
                 .fill(LinearGradient(colors: [.utemAzul, .utemVerde], startPoint: .bottomLeading, endPoint: .topTrailing ))
                 .frame(width: UIScreen.main.bounds.width, height: 100)
                 .ignoresSafeArea()
                 .position(x: UIScreen.main.bounds.width/2, y: 0)
                 .zIndex(1)
              
            List {
                VStack {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .padding()
                            
                            VStack(alignment: .leading){
                                Text(perfil.nombres.capitalized)
                                    .foregroundColor(.black)
                                Text(perfil.apellidos.capitalized)
                                    .foregroundColor(.black)
                                
                                Text(perfil.rutCompleto.uppercased())
                                    .foregroundColor(.grey)
                                    .font(.footnote)
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        .padding(.top, 5)
                        Divider()
                        VStack(alignment: .leading){
                            HStack {
                                VStack(alignment: .leading){
                                    Text("MOTIVO")
                                        .foregroundColor(.grey)
                                        .fontWeight(.bold)
                                        .font(.callout)
                                    if permiso == nil {
                                        Text("Desconocido")
                                            .foregroundColor(.grey)
                                            .fontWeight(.light)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                            .redacted(reason: .placeholder)
                                            .shimmering()
                                    } else {
                                        Text(permiso?.motivo ?? "Desconocido")
                                            .foregroundColor(.grey)
                                            .fontWeight(.light)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                    }
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
                                    if permiso == nil {
                                        Text("Desconocida")
                                            .foregroundColor(.grey)
                                            .fontWeight(.light)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                            .redacted(reason: .placeholder)
                                            .shimmering()
                                    } else {
                                        Text(permiso?.jornada ?? "Desconocida")
                                            .foregroundColor(.grey)
                                            .fontWeight(.light)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .leading){
                                    Text("VIGENCIA")
                                        .foregroundColor(.grey)
                                        .fontWeight(.bold)
                                        .font(.callout)
                                    if permiso == nil  {
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
                            
                            Text("Permiso generado el:")
                                .foregroundColor(.grey)
                                .font(.footnote)
                            
                            if permiso == nil {
                                Text("00/00/0000")
                                    .foregroundColor(.grey)
                                    .font(.footnote)
                                    .padding(.bottom, 20.0)
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                            } else {
                                Text(permisoSimple.fechaSolicitud.replacing("-", with: "/").replacing("T00:00:00.000Z", with: "").split(separator: "/").reversed().joined(separator: "/"))
                                    .foregroundColor(.grey)
                                    .font(.footnote)
                                    .padding(.bottom, 20.0)
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 5)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .background(.white)
                    .cornerRadius(15)
                    
                    
                    Spacer()
                }.padding()
                /*.toast(isPresenting: $showErrorToast) {
                    AlertToast(type: .error(.red), title: "Error!", subTitle: error ?? "Error desconocido! Por favor intenta más tarde.")
                }*/
            }
            .refreshable {
                self.error = nil
                self.permiso = nil
                self.qrImage = nil
                try? GlobalStorage.shared?.removeObject(forKey: "permiso.\(permisoSimple.id)")
                
                let permiso = try? await PermisosService.getPermisoDetallado(permisoSimple: permisoSimple)
                self.permiso = permiso
               
                let image = await PermisosService.generateQr(permiso: permiso!)
                self.qrImage = image
            }
             
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
            self.error = nil
            
            Task {
                do {
                    let permiso = try await PermisosService.getPermisoDetallado(permisoSimple: permisoSimple)
                    self.permiso = permiso
                    
                    let image = await PermisosService.generateQr(permiso: permiso)
                    self.qrImage = image
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }
        .onChange(of: error) { newValue in
            self.showErrorToast = newValue != nil
        }
    }
}
