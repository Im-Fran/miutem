import SwiftUI
import AVKit
import AVFoundation
import PopupView
import ActivityIndicatorView

struct LoginView: View {
    
    @EnvironmentObject var authService: AuthService
    
    @State private var username: String = ""
    @FocusState private var isUsernameFocused: Bool
    
    @State private var password: String = ""
    @FocusState private var isPasswordFocused: Bool
    
    @State private var isShowingLoadingIndicator: Bool = false
    @State private var isShowingStatusToast: Bool = false
    
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
                            TextField(text: $username) {
                                Text("Usuario/Correo UTEM")
                                    .foregroundColor(.white)
                            }
                            .onSubmit {
                                // validate(name: username)
                            }
                            .focused($isUsernameFocused)
                            .textInputAutocapitalization(.never)
                        }
                        .padding()
                        .background(Capsule().stroke(.white, lineWidth: 2)) // Apply oval shape
                        
                        Spacer().frame(height: 20)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                            SecureField(text: $password) {
                                Text("Contraseña")
                                    .foregroundColor(.white)
                            }
                            .onSubmit {
                                // validate(password: password)
                            }
                            .textInputAutocapitalization(.never)
                            .focused($isPasswordFocused)
                        }
                        .padding()
                        .background(Capsule().stroke(.white, lineWidth: 2)) // Apply oval shape
                    }
                    .frame(width: UIScreen.main.bounds.width * 4/5) // Set width to 4/5 of the screen
                    .foregroundColor(.white)
                    
                    Spacer().frame(height: 50)
                    
                    Button("Iniciar") {
                        if(isUsernameFocused) {
                            isUsernameFocused.toggle()
                        }
                        
                        if(isPasswordFocused) {
                            isPasswordFocused.toggle()
                        }
                        
                        isShowingLoadingIndicator.toggle()
                        authService.storeCredentials(credentials: Credentials(username: self.username, password: self.password))
                        authService.attemptLogin {
                            if(authService.status != "ok") {
                                isShowingStatusToast.toggle()
                            }
                            isShowingLoadingIndicator.toggle()
                        }
                    }
                    .disabled(isShowingLoadingIndicator || isShowingStatusToast)
                    .frame(width: UIScreen.main.bounds.width * 1/4, height: 35) // Set width to 4/5 of the screen
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
            .popup(isPresented: $isShowingStatusToast) {
                VStack {
                    Text("\(Text("Error").font(.title3).fontWeight(.bold))\n\(authService.status ?? "Por favor verifica tus credenciales!")")
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
        }
        .onAppear {
            let credentials: Credentials = authService.getStoredCredentials()
            username = credentials.username
            password = credentials.password
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
            
            let asset = AVAsset(url: videoURL)
            let item = AVPlayerItem(asset: asset)
            
            looper = AVPlayerLooper(player: player, templateItem: item)
            player.replaceCurrentItem(with: item)
            player.play()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @StateObject static var authService: AuthService = AuthService()
    static var previews: some View {
        LoginView()
            .environmentObject(authService)
    }
}
