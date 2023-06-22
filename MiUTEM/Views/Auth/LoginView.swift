import SwiftUI
import AVKit
import AVFoundation

struct LoginView: View {
    var body: some View {
        ZStack {
            VideoPlayerView(videoName: "background")
            
            VStack {
                Spacer() // Add spacer to push the image to the top
                Image("utemLogoBlanco")
                    .resizable() // Make the image resizable
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 90)
                    .padding()
                Spacer() // Add spacer to push the image to the top
            }
            .padding()
        }
    }
}


struct VideoPlayerView: View {
    private let player = AVQueuePlayer()
    private let looper: AVPlayerLooper
    
    init(videoName: String) {
        let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4")!
        let asset = AVAsset(url: videoURL)
        let item = AVPlayerItem(asset: asset)
        self.looper = AVPlayerLooper(player: player, templateItem: item)
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .scaledToFill()
                .onDisappear {
                    player.pause()
                }
                .onAppear {
                    player.play()
                }
            
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .ignoresSafeArea()
        }.ignoresSafeArea()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
