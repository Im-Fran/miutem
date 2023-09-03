//
//  PermisoDetail_Informacion.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 03-09-23.
//

import SwiftUI

struct PermisoDetail_Informacion: View {
    
    @Binding var permiso: Permiso?
    @Binding var permisoSimple: PermisoSimple
    
    var body: some View {
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
    }
}
