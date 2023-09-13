//
//  MenuView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 27-06-23.
//

import SwiftUI

struct MenuView: View {
    
    @Binding var isSidebarVisible: Bool
    @Binding var perfil: Perfil?
    
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.8
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.6))
            .opacity(isSidebarVisible ? 1 : 0)
            .animation(.easeInOut.delay(0.2), value: isSidebarVisible)
            .onTapGesture {
                isSidebarVisible.toggle()
            }
            
            content
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var content: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top){
                Color.white
                VStack(alignment: .leading){
                    userProfile
                    menuLinks
                        .padding(20)
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10){
                        Divider()
                        VStack(alignment: .leading, spacing: 40){
                            Button(action: {}) {
                                Label {
                                    Text(verbatim: "Acerca de MiUTEM")
                                        .foregroundColor(.black)
                                        .font(.system(size: 18))
                                        .padding(.leading, 20)
                                } icon: {
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.brandGrey)
                                }
                            }
                            
                            
                            Button(action: { CredentialsService.logout() }) {
                                Button(action: {}) {
                                    Label {
                                        Text(verbatim: "Cerrar Sesión")
                                            .foregroundColor(.black)
                                            .font(.system(size: 18))
                                            .padding(.leading, 20)
                                    } icon: {
                                        Image(systemName: "multiply.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.brandGrey)
                                    }
                                }
                            }
                        }
                        .padding(20)
                    }
                    .padding(.bottom, 30)
                }
                
                Spacer()
            }
            .frame(width: sideBarWidth)
            .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
            .animation(.default, value: isSidebarVisible)
            
            Spacer()
        }
    }
    
    var userProfile: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.utemAzul, Color.utemVerde]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .frame(width: sideBarWidth, height: 200)
            .overlay {
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        Circle()
                            .fill(Color(hex: 0xFF1A9C9A))
                            .frame(width: 70, height: 70)
                            .overlay {
                                Text(perfil?.iniciales ?? "N/N")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text(perfil?.nombreCompleto.capitalized ?? "N/M")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .semibold))
                            Text(verbatim: perfil?.correoUtem ?? "nn@utem.cl")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .light))
                        }
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
    }
    
    var menuLinks: some View {
        VStack(alignment: .leading, spacing: 40){
            Button(action: {}) {
                Label {
                    Text(verbatim: "Perfil")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                        .padding(.leading, 20)
                } icon: {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.brandGrey)
                }
            }
            
            
            Button(action: {}) {
                Label {
                    Text(verbatim: "Asignaturas")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                        .padding(.leading, 20)
                } icon: {
                    Image(systemName: "text.book.closed.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.brandGrey)
                }
            }
            
            
            Button(action: {}) {
                Label {
                    Text(verbatim: "Horario")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                        .padding(.leading, 20)
                } icon: {
                    Image(systemName: "clock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.brandGrey)
                }
            }
            
            
            Button(action: {}) {
                Label {
                    HStack {
                        Text(verbatim: "Credencial")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(Color.red)
                            .cornerRadius(20)
                            .overlay {
                                Text(verbatim: "Nuevo")
                                    .foregroundColor(.white)
                            }
                            .frame(width: 65, height: 25)
                    }
                } icon: {
                    Image(systemName: "person.text.rectangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.brandGrey)
                }
            }
        }
    }
}
