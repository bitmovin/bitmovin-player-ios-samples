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
    private let sources: [Source]
    private let playlistConfig: PlaylistConfig

    init() {
        // Create player configuration with the default settings
        let playerConfig = PlayerConfig()

        // Enable auto play
        playerConfig.playbackConfig.isAutoplayEnabled = true

        // Set your player license key on the player configuration
        playerConfig.key = playerLicenseKey

        // Create analytics configuration with your analytics license key
        let analyticsConfig = AnalyticsConfig(licenseKey: analyticsLicenseKey)

        // Create player based on player and analytics configurations
        player = PlayerFactory.create(
            playerConfig: playerConfig,
            analyticsConfig: analyticsConfig
        )

        sources = createPlaylist()

        // Configure playlist-specific options
        let playlistOptions = PlaylistOptions(preloadAllSources: false)

        // Create a playlist configuration containing the playlist items (sources) and the playlist options
        playlistConfig = PlaylistConfig(
            sources: sources,
            options: playlistOptions
        )

        // Create player view configuration
        playerViewConfig = PlayerViewConfig()

       // Load the playlist configuration into the player instance
        player.load(playlistConfig: playlistConfig)
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
            // Listen to events from all sources
            .onReceive(Publishers.MergeMany(sources.map { source in
                source.events.on(SourceEvent.self).map { event in (event, source) }
            })) { (event: SourceEvent, source: Source) in
                let sourceIdentifier = source.sourceConfig.title ?? source.sourceConfig.url.absoluteString
                dump(event, name: "[Source Event] - \(sourceIdentifier)", maxDepth: 1)
            }
        }
        // `edgesIgnoringSafeArea` is needed because AVKit only shows controls when video content occupies the whole screen
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func createPlaylist() -> [Source] {
    guard let artOfMotionUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
          let sintelUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8") else {
        return []
    }

    return [
        createSource(
            from: artOfMotionUrl,
            title: "Art of Motion"
        ),
        createSource(
            from: sintelUrl,
            title: "Sintel"
        )
    ]
}

func createSource(from url: URL, title: String) -> Source {
    let sourceConfig = SourceConfig(url: url, type: .hls)
    sourceConfig.title = title

    return SourceFactory.create(from: sourceConfig)
}
