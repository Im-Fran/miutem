//
//  PermisoPreview.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 25-06-23.
//

import SwiftUI
import ActivityIndicatorView

struct PermisoPreview: View {
    
    @State var isLoading: Bool = false
    
    var body: some View {
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
                
                
                ActivityIndicatorView(isVisible: $isLoading, type: .growingCircle)
                    .foregroundColor(Color(hex: 0xFF009D9B))
                    .frame(width: 75, height: 75)
            }
        } else {
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
}


struct PermisoPreview_Previews: PreviewProvider {
    static var previews: some View {
        PermisoPreview()
    }
}

