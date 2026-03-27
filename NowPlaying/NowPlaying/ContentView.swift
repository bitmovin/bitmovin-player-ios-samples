//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Combine
import MediaPlayer
import SwiftUI

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
private let playerLicenseKey = "<PLAYER_LICENSE_KEY>"

final class ViewModel: ObservableObject {
    let player: Player
    private let sourceConfig: SourceConfig
    let playerViewConfig = PlayerViewConfig()
    
    init() {
        // Create player configuration with Now Playing information enabled
        let playerConfig = PlayerConfig()
        playerConfig.key = playerLicenseKey
        playerConfig.nowPlayingConfig.isNowPlayingInfoEnabled = true
        // Optionally, disable automatic pausing when the app moves to the background
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = true

        // Create a source config that has some meta data like a poster image and a title
        guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let posterUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/MI201109210084/poster.jpg") else {
            fatalError("Invalid URLs")
        }

        sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        sourceConfig.posterSource = posterUrl
        sourceConfig.title = "Now Playing info demo"

        // Create player based on player configuration
        player = PlayerFactory.createPlayer(
            playerConfig: playerConfig
        )

        // Get the shared remote command center
        let commandCenter = MPRemoteCommandCenter.shared()

        // Enable a command, by adding a handler for a command that is not part of the default commands
        commandCenter.likeCommand.addTarget { _ in
            commandCenter.likeCommand.isActive.toggle()
            return .success
        }

        // Customization: Some commands have customization options. E.g. the skip commands
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        
        handleAudioSessionCategorySetting()
    }

    func loadSource() {
        player.load(sourceConfig: sourceConfig)
    }
    
    /* Set AVAudioSessionCategoryPlayback category on the audio session. This category indicates that audio playback
     is a central feature of your app. When you specify this category, your app’s audio continues with the Ring/Silent
     switch set to silent mode (iOS only). With this category, your app can also play background audio if you're
     using the Audio, AirPlay, and Picture in Picture background mode. To enable this mode, under the Capabilities
     tab in your Xcode project, set the Background Modes switch to ON and select the “Audio, AirPlay, and Picture in
     Picture” option under the list of available modes. */
    private func handleAudioSessionCategorySetting() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup failed:", error)
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VideoPlayerView(
            player: viewModel.player,
            playerViewConfig: viewModel.playerViewConfig
        )
        .background(Color.black)
        .cornerRadius(25)
        .padding()
        .onAppear {
            viewModel.loadSource()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
