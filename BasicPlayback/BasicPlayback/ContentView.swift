//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Combine
import SwiftUI

struct ContentView: View {
    private let player: Player
    private let playerViewConfig: PlayerViewConfig
    private var sourceConfig: SourceConfig {
        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let posterUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/poster.jpg") else {
            fatalError("Invalid URL")
        }
        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        // Set a poster image
        sourceConfig.posterSource = posterUrl

        return sourceConfig
    }

    init() {
        // Create player configuration
        let playerConfig = PlayerConfig()

        // Create player based on player config
        player = PlayerFactory.create(playerConfig: playerConfig)

        // Create player view configuration
        playerViewConfig = PlayerViewConfig()
    }

    var body: some View {
        ZStack {
            Color.black

            VideoPlayerView(
                player: player,
                playerViewConfig: playerViewConfig
            )
            .onReceive(player.events.on(PlayerEvent.self)) { (event: PlayerEvent) in
                dump(event, name: "[Player Event]", maxDepth: 1)
            }
            .onReceive(player.events.on(SourceEvent.self)) { (event: SourceEvent) in
                dump(event, name: "[Source Event]", maxDepth: 1)
            }
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
