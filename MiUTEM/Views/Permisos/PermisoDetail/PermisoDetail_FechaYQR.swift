//
//  PermisoDetail_FechaYQR.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 03-09-23.
//

import SwiftUI
import Photos
import ImageViewer

struct PermisoDetail_FechaYQR: View {
    
    @Binding var permiso: Permiso?
    @Binding var permisoSimple: PermisoSimple
    @Binding var qrImage: UIImage?
    
    @State var image: Image? = nil
    @State var showQR: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center){
                if qrImage == nil {
                    Image(systemName: "qrcode")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .padding(.vertical, 15)
                        .redacted(reason: .placeholder)
                        .shimmering()
                } else {
                    Button(action: { self.showQR.toggle() }){
                        Image(uiImage: qrImage!)
                            .resizable()
                            .frame(width: 128, height: 128)
                            .padding(.vertical, 15)
                    }
                    .fullScreenCover(isPresented: self.$showQR) {    
                        ZStack {
                            Color.black
                                .opacity(0.95)
                                .ignoresSafeArea(edges: .all)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                
                                Spacer()
                                
                                VStack {
                                    Image(uiImage: qrImage!)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(15)
                                }
                                
                                Spacer()
                            }
                        }
                        .onTapGesture {
                            self.showQR.toggle()
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { val in
                                    self.showQR.toggle()
                                }
                        )
                    }
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
    }
}

