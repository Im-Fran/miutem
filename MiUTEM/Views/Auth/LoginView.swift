import SwiftUI
import AVKit
import AVFoundation
import PopupView
import ActivityIndicatorView
import Combine
import AlertToast

struct LoginView: View {
    
    @EnvironmentObject var appService: AppService
    
    @State private var correo: String = ""
    @FocusState private var isCorreoFocused: Bool
    
    @State private var contrasenia: String = ""
    @FocusState private var isContraseniaFocused: Bool
    
    @State private var isShowingLoadingIndicator: Bool = false
    
    @State private var errorMessage: String? = nil
    @State private var isPopupPresented: Bool = true
    
    @State var cancellables: [AnyCancellable] = []
    
    var body: some View {
        ZStack {
             VideoPlayerView(videoName: "background")

             ActivityIndicatorView(isVisible: $isShowingLoadingIndicator, type: .growingCircle)
                 .foregroundColor(Color(hex: 0xFF009D9B))
                 .frame(width: 75, height: 75)

             VStack {
                 Spacer() // Add spacer to push the image to the top
                 Image("utemLogoBlanco")
                     .resizable() // Make the image resizable
                     .aspectRatio(contentMode: .fit)
                     .frame(height: 90)
                     .padding()
                 Spacer() // Add spacer to separate form and utemLogoBlanco

                 // Form
                 VStack {
                     VStack {
                         HStack {
                             Image(systemName: "person.fill")
                             TextField(text: $correo) {
                                 Text("Usuario/Correo UTEM")
                                     .foregroundColor(.white)
                             }
                             .focused($isCorreoFocused)
                             .textInputAutocapitalization(.never)
                         }
                         .padding()
                         .background(Capsule().stroke(.white, lineWidth: 2)) // Apply oval shape

                         Spacer().frame(height: 20)

                         HStack {
                             Image(systemName: "lock.fill")
                             SecureField(text: $contrasenia) {
                                 Text("Contraseña")
                                     .foregroundColor(.white)
                             }
                             .textInputAutocapitalization(.never)
                             .focused($isContraseniaFocused)
                         }
                         .padding()
                         .background(Capsule().stroke(.white, lineWidth: 2)) // Apply oval shape
                     }
                     .frame(width: UIScreen.main.bounds.width * 4/5) // Set width to 4/5 of the screen
                     .foregroundColor(.white)

                     Spacer().frame(height: 50)

                     Button("Iniciar") {
                         errorMessage = nil
                         isShowingLoadingIndicator = true // Show loading indicator when button is tapped

                         if isCorreoFocused {
                             isCorreoFocused.toggle()
                         }

                         if isContraseniaFocused {
                             isContraseniaFocused.toggle()
                         }

                         if contrasenia.isEmpty {
                             errorMessage = "Por favor ingresa una contraseña!"
                             isShowingLoadingIndicator = false
                             return
                         }

                         if correo.isEmpty {
                             errorMessage = "Por favor ingresa un usuario/correo!"
                             isShowingLoadingIndicator = false
                             return
                         }

                         appService.authService.storeCredentials(credentials: Credentials(correo: correo, contrasenia: contrasenia))

                         appService.authService.getPerfil()
                             .receive(on: DispatchQueue.main)
                             .sink(receiveCompletion: { completion in
                                 switch completion {
                                 case .failure(let error):
                                     errorMessage = error.localizedDescription
                                     isShowingLoadingIndicator = false
                                     break
                                 case .finished:
                                     isShowingLoadingIndicator = false
                                     break
                                 }
                             }, receiveValue: { perfil in
                                 appService.authService.perfil = perfil
                                 isShowingLoadingIndicator = false
                             }).store(in: &cancellables)
                     }
                     .disabled(isShowingLoadingIndicator || isPopupPresented) // Disable button while loading
                     .frame(width: UIScreen.main.bounds.width * 1/4, height: 35)
                     .background(Capsule().fill(Color(hex: 0xFF009D9B)))
                     .font(.title3)
                     .fontWeight(.semibold)
                     .foregroundColor(.white)
                     .padding(.all)

                 }
                 .padding()
                 .scrollDismissesKeyboard(.automatic)

                 Spacer() // Add spacer to push the form to the top

                 Text("Hecho con ❤️ por el \(Text("Club de Desarrollo Experimental").fontWeight(.semibold)) junto a SISEI.")
                     .frame(width: UIScreen.main.bounds.width * 4/5, alignment: .center)
                     .multilineTextAlignment(.center)
                     .lineLimit(2)
                     .foregroundColor(.white)
             }
             .toast(isPresenting: $isPopupPresented) {
                 AlertToast(type: .regular, title: "Message Sent!")
             }
             /*
              .popup(isPresented: $isPopupPresented) {
                  VStack {
                      Text("\(Text("Error").font(.title3).fontWeight(.bold))\n\(self.errorMessage ?? "No sabemos que ocurrió! Por favor intenta más tarde.")")
                          .multilineTextAlignment(.leading)
                          .padding()
                  }
                  .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                  .foregroundColor(.white)
                  .background(Rectangle().fill(Color(hex: 0xFF009D9B)).cornerRadius(15))
                  .padding()
              } customize: {
                  $0.autohideIn(5)
                      .position(.bottom)
                      .dragToDismiss(true)
              }
              */
        }
        .onAppear {
            let credentials: Credentials = appService.authService.getStoredCredentials()
            
            correo = credentials.correo
            contrasenia = credentials.contrasenia
            
            
        }
        .onDisappear {
            cancellables.forEach { it in it.cancel() }
        }
    }
}

struct VideoPlayerView: View {
    @State private var player = AVQueuePlayer()
    @State private var looper: AVPlayerLooper?
    var videoName: String
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .scaledToFill()
                .disabled(true)
            
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .ignoresSafeArea()
        }
        .onAppear {
            guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
                return
            }
            
            // Esto permite que no se pause la musica mientras se está en el login
            try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try? AVAudioSession.sharedInstance().setActive(true)
            
            let asset = AVAsset(url: videoURL)
            let item = AVPlayerItem(asset: asset)
            
            looper = AVPlayerLooper(player: player, templateItem: item)
            player.replaceCurrentItem(with: item)
            player.play()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @StateObject static var appService = AppService()
    static var previews: some View {
        LoginView()
            .environmentObject(appService)
    }
}
