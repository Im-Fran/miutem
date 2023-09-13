//
//  PermisoDetail_Perfil.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 03-09-23.
//

import SwiftUI

struct PermisoDetail_Perfil: View {
    
    @State var perfil: Perfil
    
    var body: some View {
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
    }
}
