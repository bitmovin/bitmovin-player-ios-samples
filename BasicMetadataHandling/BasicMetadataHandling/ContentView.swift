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

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
private let playerLicenseKey = "<PLAYER_LICENSE_KEY>"
// You can find your analytics license key on the analytics license dashboard:
// https://bitmovin.com/dashboard/analytics/licenses
private let analyticsLicenseKey = "<ANALYTICS_LICENSE_KEY>"

struct ContentView: View {
    private let player: Player
    private let playerViewConfig: PlayerViewConfig
    private var sourceConfig: SourceConfig {
        // Define needed resources
        guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/metadata/media.m3u8") else {
            fatalError("Invalid URL")
        }

        return SourceConfig(url: streamUrl, type: .hls)
    }

    init() {
        // Create player configuration
        let playerConfig = PlayerConfig()

        // Set your player license key on the player configuration
        playerConfig.key = playerLicenseKey

        // Create analytics configuration with your analytics license key
        let analyticsConfig = AnalyticsConfig(licenseKey: analyticsLicenseKey)

        // Create player based on player and analytics configurations
        player = PlayerFactory.createPlayer(
            playerConfig: playerConfig,
            analytics: .enabled(
                analyticsConfig: analyticsConfig
            )
        )

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
            .onReceive(player.events.on(MetadataEvent.self)) { (event: MetadataEvent) in
                guard event.metadataType == .ID3 else { return }
                event.metadata.entries.forEach { entry in
                    if let metadataEntry = entry as? AVMetadataItem,
                       let id3Key = metadataEntry.key {
                        print("Received metadata with key: \(id3Key)")
                    }
                }
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
