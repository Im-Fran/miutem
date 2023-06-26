//
//  PermisoPreview.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 25-06-23.
//

import SwiftUI

struct PermisoPreview: View {
    
    var isLoading: Bool = true
    
    init() {
        Task {
            try await Task.sleep(nanoseconds: UInt64(5.0 * Double(NSEC_PER_SEC)))
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "qrcode")
                    .resizable()
                    .frame(width: 48, height: 48)
                VStack {
                    Text("Estudiante\n\(Text("Permiso académico de ingreso a clases").foregroundColor(.brand).fontWeight(.bold))")
                        .font(.body)
                        .foregroundColor(.mediumGrey)
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
        .frame(width: UIScreen.main.bounds.width * (2/3), height: 175)
        .background(.white)
        .cornerRadius(15)
    }
}

/*
struct PermisoPreview_Previews: PreviewProvider {
    static var previews: some View {
        PermisoPreview()
    }
}
*/
