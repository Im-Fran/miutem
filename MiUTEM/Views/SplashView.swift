//
//  SplashView.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 20-06-23.
//

import SwiftUI
import RiveRuntime

class LogoAnimation: RiveViewModel {
        
    @Binding var isActive: Bool  // Add the binding state property
        
    init(isActive: Binding<Bool>) {
        self._isActive = isActive  // Initialize the binding state property
        super.init(fileName: "utem", stateMachineName: "State Machine 1", autoPlay: false)
    }
        
    override func player(pausedWithModel riveModel: RiveModel?) {
        if riveModel?.stateMachine?.name() != nil {
            isActive.toggle()
        }
    }
}

struct SplashView: View {
    @Binding var isActive: Bool
     
    var body: some View {
        let logoAnimation = LogoAnimation(isActive: $isActive)
        VStack {
             ZStack {
                 Spacer().frame(width: 1.0)
                 VStack {
                     logoAnimation.view()
                         .aspectRatio(contentMode: .fit)
                 }
                 .padding()
                 .onAppear {
                     logoAnimation.play()
                 }
             }
             .frame(alignment: .center)
             
             Text("Versión \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                 .foregroundColor(.white)
                 .font(.title3)
                 .fontWeight(.semibold)
                 
         }
         .background(LinearGradient(colors: [Color("brandGreen"), Color("brandBlue")], startPoint: .topTrailing, endPoint: .bottomLeading))
     }
}


struct SplashView_Previews: PreviewProvider {
    @State static var isActive: Bool = true
    static var previews: some View {
        if isActive {
            SplashView(isActive: $isActive)
        } else {
            HomeView()
        }
    }
}
