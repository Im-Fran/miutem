//
//  PermisoDetail_FechaYQR.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 03-09-23.
//

import SwiftUI

struct PermisoDetail_FechaYQR: View {
    
    @Binding var permiso: Permiso?
    @Binding var permisoSimple: PermisoSimple
    @Binding var qrImage: UIImage?
    
    var body: some View {
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
}

