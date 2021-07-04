//
//  PlayerView.swift
//  TV
//
//  Created by Alek Sai on 03/07/2021.
//

import SwiftUI
import TVVLCKit

class PlayerDelegate: NSObject, VLCMediaPlayerDelegate {
    
    static var shared = PlayerDelegate()
    
    public let mediaPlayer = VLCMediaPlayer()
    
    public var onData: (([String], [String], String) -> ())?
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
//        print(aNotification)
        
        onData?(mediaPlayer.audioTrackNames as! [String], mediaPlayer.videoSubTitlesNames as! [String], "\(Int(mediaPlayer.videoSize.width))x\(Int(mediaPlayer.videoSize.height))")
    }
    
    func mediaPlayerSnapshot(_ aNotification: Notification!) {
//        print(aNotification)
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
//        print(aNotification)
    }
    
}

struct Player: UIViewRepresentable {
    
    @Binding var url: URL?
    
    @Binding var resolution: String
    
    @Binding var audioTracks: [String]
    @Binding var audioTrack: Int
    
    @Binding var subtitles: [String]
    @Binding var subtitle: Int
    
    let videoView = UIView(frame: UIScreen.main.bounds)
    let playerDelegate = PlayerDelegate.shared
    
    func makeUIView(context: Context) -> UIView {
        videoView.backgroundColor = .black

        if let url = url {
            playerDelegate.mediaPlayer.drawable = videoView
            playerDelegate.mediaPlayer.media = VLCMedia(url: url)
            
            playerDelegate.mediaPlayer.delegate = playerDelegate
            
            playerDelegate.onData = { audioTracks, subtitles, resolution in
                self.audioTracks = audioTracks
                self.subtitles = subtitles
                self.resolution = resolution
            }
            
            playerDelegate.mediaPlayer.play()
        }
        
        return videoView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        playerDelegate.mediaPlayer.currentAudioTrackIndex = Int32(audioTrack)
        playerDelegate.mediaPlayer.currentVideoSubTitleIndex = Int32(subtitle)
    }

}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct PlayerView: View {
    
    @ObservedObject public var viewModel: PlayerViewModel = PlayerViewModelImpl(device: nil, resources: [], metadata: nil)
    
    @Namespace var mainNamespace
    @Environment(\.resetFocus) var resetFocus
    
    @State var pause = false
    
    @State var resolution = ""
    
    @State var audioTracks: [String] = []
    @State var audioTrack = 0
    
    @State var subtitles: [String] = []
    @State var subtitle = 0
    
    @State var tab = 0
    
    @Binding var playing: Bool
    
    private func playOrPause() {
        if PlayerDelegate.shared.mediaPlayer.isPlaying {
            PlayerDelegate.shared.mediaPlayer.pause()
            
            resetFocus(in: mainNamespace)
            
            withAnimation(.easeIn) {
                pause = true
            }
        } else {
            PlayerDelegate.shared.mediaPlayer.play()
            
            withAnimation(.easeIn) {
                pause = false
            }
        }
    }
    
    private func stop() {
        PlayerDelegate.shared.mediaPlayer.stop()
        
        playing = false
    }
    
    var body: some View {
        ZStack {
            Player(
                url: $viewModel.url,
                resolution: $resolution,
                audioTracks: $audioTracks, audioTrack: $audioTrack,
                subtitles: $subtitles, subtitle: $subtitle
            )
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
                .focusable(!pause)

            VStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        Picker("Tabs", selection: $tab) {
                            Text("Info").tag(0)
                            Text("Settings").tag(1)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 30)
                    
                    if tab == 0 {
                        Text(viewModel.url?.pathComponents.last ?? "hello.mkv")
                            .font(.headline)
                            .padding(.bottom, 20)

                        VStack(spacing: 6) {
                            HStack {
                                Text("Resolution".uppercased())
                                    .font(.system(size: 24, weight: .bold))
                                Text(resolution)
                            }
                        }
                    }

                    if tab == 1 {
                        HStack {
                            Text("🔊")
                                .font(.headline)
                                .padding(.bottom, 20)
                            
                            Picker("Audio", selection: $audioTrack) {
                                ForEach(Array(audioTracks.enumerated()), id: \.offset) { index, track in
                                    Text(track).tag(index)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("💬")
                                .font(.headline)
                                .padding(.bottom, 20)
                            
                            Picker("Subtitles", selection: $subtitle) {
                                ForEach(Array(subtitles.enumerated()), id: \.offset) { index, subtitle in
                                    Text(subtitle).tag(index)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(50)
                .background(VisualEffectView(effect: UIBlurEffect(style: .dark)).edgesIgnoringSafeArea(.all))
                .offset(y: pause ? 0 : -UIScreen.main.bounds.height)

                Spacer()
            }
        }
        .onLongPressGesture(minimumDuration: 0.01, pressing: { _ in }, perform: playOrPause)
        .onPlayPauseCommand(perform: playOrPause)
        .onExitCommand(perform: stop)
    }

}

struct FolderView_Preview: PreviewProvider {
    static var previews: some View {
        PlayerView(viewModel: PlayerViewModel(), playing: Binding(get: { true }, set: { _ in }))
    }
}

struct FolderView_Preview_Empty: PreviewProvider {
    static var previews: some View {
        PlayerView(viewModel: PlayerViewModel(), playing: Binding(get: { true }, set: { _ in }))
    }
}
