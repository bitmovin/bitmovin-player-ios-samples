//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Combine
import SwiftUI
import MediaPlayer

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
private let playerLicenseKey = "<PLAYER_LICENSE_KEY>"

struct ContentView: View {
    private let player: Player
    private let sourceConfig: SourceConfig

    init() {
        // Create player configuration with Now Playing information enabled
        let playerConfig = PlayerConfig()
        playerConfig.key = playerLicenseKey
        playerConfig.nowPlayingConfig.isNowPlayingInfoEnabled = true

        // Create a source config that has some meta data like a poster image and a title
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let posterUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/poster.jpg") else {
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
        commandCenter.likeCommand.addTarget { event in
            commandCenter.likeCommand.isActive.toggle()
            return .success
        }

        // Customization: Some commands have customization options. E.g. the skip commands
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
    }

    var body: some View {
        ZStack {
            Color.black

            VideoPlayerView(
                player: player,
                playerViewConfig: PlayerViewConfig()
            )
        }
        .padding()
        .onAppear {
            player.load(sourceConfig: sourceConfig)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
