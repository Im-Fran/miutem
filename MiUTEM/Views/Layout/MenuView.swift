//
//  MenuView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 27-06-23.
//

import SwiftUI
import Combine

struct MenuView: View {
    
    @Binding var isMenuVisible: Bool
    
    @State var perfil: Perfil?
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.3))
            .opacity(isMenuVisible ? 1 : 0)
            .animation(.easeIn.delay(0.25), value: isMenuVisible)
            .onTapGesture {
                self.isMenuVisible.toggle()
            }

            
             if isMenuVisible && perfil != nil {
                 HStack {
                     VStack(alignment: .leading) {
                         Rectangle()
                             .fill(LinearGradient(
                                 colors: [.utemAzul, .utemVerde],
                                 startPoint: .bottomLeading,
                                 endPoint: .topTrailing
                             ))
                             .overlay {
                                 VStack(alignment: .leading) {
                                     Circle()
                                         .fill(.brand)
                                         .frame(width: 75, height: 75)
                                         .overlay {
                                             Text(perfil?.iniciales ?? "")
                                                 .foregroundColor(.white)
                                         }
                                     
                                     Text(perfil?.nombres.capitalized ?? "")
                                         .bold()
                                         .foregroundColor(.white)
                                     Text(perfil?.apellidos.capitalized ?? "")
                                         .bold()
                                         .foregroundColor(.white)
                                     Text(verbatim: perfil?.correoUtem ?? "")
                                         .foregroundColor(.white)
                                 }
                                 .padding(.top, 50)
                                 .padding()
                             }
                             .frame(maxHeight: 200)
                             .ignoresSafeArea()
                         
                         Divider()
                         
                         VStack {
                             Text("Hello, World")
                         }
                         .padding()
                         
                         Spacer()
                     }
                     .frame(width: UIScreen.main.bounds.width / 1.5)
                     .background(.white)
                     
                     Spacer()
                 }
             }
        }
        .animation(.default, value: isMenuVisible)
        .onAppear {
            Task {
                let perfil = try? await AuthService.getPerfil()
                self.perfil = perfil
            }
        }
    }
}


struct MenuView_Previews: PreviewProvider {
    @State private static var isMenuVisible: Bool = true
    
    static var previews: some View {
        MenuView(isMenuVisible: $isMenuVisible)
            .ignoresSafeArea()
    }
}
