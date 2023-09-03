import SwiftUI
import AVKit
import AVFoundation
import ActivityIndicatorView
import Combine
import SystemNotification

struct LoginView: View {
    
    @StateObject var notificationContext = SystemNotificationContext()
    
    @Binding var isLoggedIn: Bool
    
    @State private var correo: String = ""
    
    @State private var contrasenia: String = ""
    
    @State private var isShowingLoadingIndicator: Bool = false
    
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
                         }
                         .padding()
                         .background(Capsule().stroke(.white, lineWidth: 2)) // Apply oval shape
                     }
                     .frame(width: UIScreen.main.bounds.width * 4/5) // Set width to 4/5 of the screen
                     .foregroundColor(.white)

                     Spacer().frame(height: 50)

                     Button("Iniciar") {
                         isShowingLoadingIndicator = true // Show loading indicator when button is tapped

                         if contrasenia.isEmpty {
                             showError(error: "Ingresa una contraseña válida!")
                             isShowingLoadingIndicator = false
                             return
                         }

                         if correo.isEmpty {
                             showError(error: "Por favor ingresa un usuario/correo!")
                             isShowingLoadingIndicator = false
                             return
                         }

                         CredentialsService.storeCredentials(credentials: Credentials(correo: correo, contrasenia: contrasenia))
                         
                         Task {
                             do {
                                 _ = try await AuthService.getPerfil()
                                 isLoggedIn.toggle()
                             } catch {
                                 print(error)
                                 showError(error: (error as? ServerError)?.mensaje ?? error.localizedDescription)
                             }
                             isShowingLoadingIndicator = false
                         }
                     }
                     .disabled(isShowingLoadingIndicator || notificationContext.isActive) // Disable button while loading
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
             .onTapGesture {
                 UIApplication.shared.inputView?.endEditing(true)
             }
        }
        .systemNotification(notificationContext)
        .onAppear {
            let credentials = CredentialsService.getStoredCredentials()
            
            correo = credentials.correo
            contrasenia = credentials.contrasenia
        }
    }
    
    func showError(error: String) {
        notificationContext.present(configuration: .init(animation: .easeInOut, duration: 5), style: .init(backgroundColor: Color(hex: 0xFF009D9B), edge: .bottom)) {
            SystemNotificationMessage(
                icon: Image(systemName: "x.circle"),
                title: "Error",
                text: "\(error)",
                style: .init(
                    iconColor: .red,
                    iconFont: .headline,
                    textColor: .white,
                    titleColor: .white,
                    titleFont: .headline
                )
            )
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
    @State private static var isLoggedIn = false
    static var previews: some View {
        LoginView(isLoggedIn: $isLoggedIn)
    }
}
