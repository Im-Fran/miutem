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
        NavigationStack {
            VStack {
                List {
                    VStack {
                        PermisoDetail_Perfil(perfil: self.perfil)
                        Divider()
                        PermisoDetail_Informacion(permiso: $permiso, permisoSimple: $permisoSimple)
                        .padding()
                        Divider()
                        PermisoDetail_FechaYQR(permiso: $permiso, permisoSimple: $permisoSimple, qrImage: $qrImage)
                    }
                    .listRowBackground(Color.lightGrey)
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .background(.white)
                    .cornerRadius(15)
                }
                .scrollContentBackground(.hidden)
                .padding(.top)
                .background(.lightGrey, ignoresSafeAreaEdges: .bottom)
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
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.utemAzul, Color.utemVerde]),
                startPoint: .leading,
                endPoint: .trailing
            ), ignoresSafeAreaEdges: .all)
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
            
            /*.toast(isPresenting: $showErrorToast) {
                AlertToast(type: .error(.red), title: "Error!", subTitle: error ?? "Error desconocido! Por favor intenta más tarde.")
            }*/
        }
    }
}
