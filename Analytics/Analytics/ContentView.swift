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
        guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let posterUrl = URL(string: "https://cdn.bitmovin.com/content/assets/MI201109210084/poster.jpg") else {
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

        // Set your player license key on the player configuration
        playerConfig.key = playerLicenseKey

        // Create a CustomData object with acts as fallback if not explicitly specified for a Source
        let customData = CustomData(
            customData1: "analytics",
            customData2: "sample"
        )

        // Configure DefaultMetadata used for the Collector instance
        let defaultMetadata = DefaultMetadata(
            customUserId: "public-player-analytics-sample",
            customData: customData
        )

        // Create analytics configuration with your analytics license key
        let analyticsConfig = AnalyticsConfig(
            licenseKey: analyticsLicenseKey
        )

        // Create player based on player and analytics configurations with DefaultMetadata set
        player = PlayerFactory.createPlayer(
            playerConfig: playerConfig,
            analytics: .enabled(
                analyticsConfig: analyticsConfig,
                defaultMetadata: defaultMetadata
            )
        )

        // Create player view configuration
        playerViewConfig = PlayerViewConfig()
    }

    var body: some View {
        VideoPlayerView(
            player: player,
            playerViewConfig: playerViewConfig
        )
        .background(Color.black)
        .cornerRadius(25)
        .padding()
        .onReceive(player.events.on(PlayerEvent.self)) { (event: PlayerEvent) in
            dump(event, name: "[Player Event]", maxDepth: 1)
        }
        .onReceive(player.events.on(SourceEvent.self)) { (event: SourceEvent) in
            dump(event, name: "[Source Event]", maxDepth: 1)
        }
        .onReceive(player.events.on(PlayerErrorEvent.self)) { _ in
            /// To access the players analytics namespace simply use it through `player.analytics`
            ///
            /// ```swift
            /// player.analytics?.userId
            /// player.analytics?.sendCustomDataEvent(customData: ...)
            /// ```
            ///

            /// To access the source's analytics namespace simply use it through `source.analytics`
            /// Can also be accessed if the Source is manually retained.
            ///
            /// ```swift
            /// source.analytics?.customData
            /// ```
            ///
        }
        .onAppear {
            // Create a Source specific CustomData object will only be used for one source
            let customData = CustomData(
                customData3: "Free-running action"
            )

            // Create a Source specific SourceMetadata object with a specific `CustomData` object
            let sourceMetadata = SourceMetadata(
                title: "Art Of Motion",
                path: "root",
                customData: customData
            )

            // Create a Source with specific Analytics metadata
            let source = SourceFactory.createSource(
                from: sourceConfig,
                sourceMetadata: sourceMetadata
            )

            player.load(source: source)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
