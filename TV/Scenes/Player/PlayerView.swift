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
    public var onTime: ((String, Int, String, Int) -> ())?
    
    func setup(view: UIView) {
        let swipeRecognizerL = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeRecognizerL.direction = .left
        
        view.addGestureRecognizer(swipeRecognizerL)
        
        let swipeRecognizerR = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRecognizerR.direction = .right
        
        view.addGestureRecognizer(swipeRecognizerR)
        
        let swipeRecognizerU = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        swipeRecognizerU.direction = .up
        
        view.addGestureRecognizer(swipeRecognizerU)
        
        let swipeRecognizerD = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeRecognizerD.direction = .down
        
        view.addGestureRecognizer(swipeRecognizerD)
    }
    
    @objc func swipeLeft() {
        print("l")
    }
    
    @objc func swipeRight() {
        print("r")
    }
    
    @objc func swipeUp() {
        print("u")
    }
    
    @objc func swipeDown() {
        print("d")
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
//        print(aNotification)
        
        onData?(mediaPlayer.audioTrackNames as! [String], mediaPlayer.videoSubTitlesNames as! [String], "\(Int(mediaPlayer.videoSize.width))x\(Int(mediaPlayer.videoSize.height))")
    }
    
    func mediaPlayerSnapshot(_ aNotification: Notification!) {
//        print(aNotification)
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
//        print(aNotification)
        
        onTime?(mediaPlayer.time.stringValue, Int(mediaPlayer.time.intValue), mediaPlayer.remainingTime.stringValue, Int(mediaPlayer.remainingTime.intValue))
    }
    
}

struct Player: UIViewRepresentable {
    
    @Binding var url: URL?
    
    @Binding var resolution: String
    
    @Binding var time: String
    @Binding var timeInt: Int
    @Binding var remainingTime: String
    @Binding var remainingTimeInt: Int
    
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
            
            playerDelegate.setup(view: videoView)
            
            playerDelegate.mediaPlayer.delegate = playerDelegate
            
            playerDelegate.onData = { audioTracks, subtitles, resolution in
                self.audioTracks = audioTracks
                self.subtitles = subtitles
                self.resolution = resolution
            }
            
            playerDelegate.onTime = { time, timeInt, remainingTime, remainingTimeInt in
                self.time = time
                self.timeInt = timeInt
                self.remainingTime = remainingTime
                self.remainingTimeInt = remainingTimeInt
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

struct PlayerView: View {
    
    @ObservedObject public var viewModel: PlayerViewModel
    
    @State var pause = false
    @Binding var playing: Bool
    
    @State var seeking = true
    @State var seekerRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    @State var time = "00:00"
    @State var timeInt = 0
    @State var remainingTime = "--:--"
    @State var remainingTimeInt = 0
    
    @State var resolution = "Loading..."
    
    @State var audioTracks: [String] = []
    @State var audioTrack = 0
    
    @State var subtitles: [String] = []
    @State var subtitle = 0
    
    @State var tab = 0
    @State var seek = 0
    
    init(item: FoldersViewModel.FolderItem?, playing: Binding<Bool>) {
        viewModel = PlayerViewModelImpl(item: item)
        
        _playing = playing
    }
    
    private func playOrPause() {
        if PlayerDelegate.shared.mediaPlayer.isPlaying {
            PlayerDelegate.shared.mediaPlayer.pause()
            
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
                time: $time, timeInt: $timeInt,
                remainingTime: $remainingTime, remainingTimeInt: $remainingTimeInt,
                audioTracks: $audioTracks, audioTrack: $audioTrack,
                subtitles: $subtitles, subtitle: $subtitle
            )
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .ignoresSafeArea()
            .focusable(!pause && !seeking)
            
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
                        Text(viewModel.name ?? "")
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
                            
                            Picker("Audio", selection: $audioTrack) {
                                ForEach(Array(audioTracks.enumerated()), id: \.offset) { index, track in
                                    Text(track).tag(index)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                        }
                        .padding(.leading, 50)
                        
                        HStack {
                            Text("💬")
                                .font(.headline)
                            
                            Picker("Subtitles", selection: $subtitle) {
                                ForEach(Array(subtitles.enumerated()), id: \.offset) { index, subtitle in
                                    Text(subtitle).tag(index)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                        }
                        .padding(.leading, 50)
                    }
                }
                .padding(50)
                .background(VisualEffectView(effect: UIBlurEffect(style: .dark)).edgesIgnoringSafeArea(.all))
                .offset(y: pause ? 0 : -UIScreen.main.bounds.height)
                
                Spacer()
                
                ZStack(alignment: .leading) {
                    HStack {
                        Text(time)
                        
                        Spacer()
                        
                        Text(remainingTime)
                    }
                    .offset(y: -50.0)
                    
//                    Picker("Seeker", selection: $seek) {
//                        ForEach(0..<9, id: \.self) { index in
//                            Text("A").tag(index)
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .onChange(of: seek) { [seek] newSeek in
//                        print(seek, newSeek)
//                    }
                    
                    Rectangle()
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .background(GeometryGetter(rect: $seekerRect))
                    
                    Rectangle()
                        .frame(width: 6, height: 30.0)
                        .background(Color.white)
                        .offset(x: remainingTimeInt == 0 ? 0 : (CGFloat(timeInt) / (CGFloat(-remainingTimeInt) + CGFloat(timeInt)) * seekerRect.width))
                }
                .padding(.horizontal, 100.0)
                .padding(.bottom, 100.0)
                .offset(y: seeking ? 0 : UIScreen.main.bounds.height)
            }
        }
        .onLongPressGesture(minimumDuration: 0.01, pressing: { _ in }, perform: playOrPause)
        .onPlayPauseCommand(perform: playOrPause)
        .onExitCommand(perform: stop)
    }
}

struct PlayerView_Preview: PreviewProvider {
    static var previews: some View {
        PlayerView(item: FoldersViewModel.FolderItem(id: "1", name: "Movie", type: "", duration: nil, resources: [], metadata: nil), playing: Binding(get: { true }, set: { _ in }))
    }
}

struct PlayerView_Preview_Empty: PreviewProvider {
    static var previews: some View {
        PlayerView(item: FoldersViewModel.FolderItem(id: "1", name: "Movie", type: "", duration: nil, resources: [], metadata: nil), playing: Binding(get: { true }, set: { _ in }))
    }
}
