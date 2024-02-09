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
    private let sourceConfig: SourceConfig
   
    init() {
        // Define needed resources
        guard let fairplayStreamUrl = URL(string: "https://fps.ezdrm.com/demo/video/ezdrm.m3u8"),
              let certificateUrl = URL(string: "https://fps.ezdrm.com/demo/video/eleisure.cer"),
              let licenseUrl = URL(string: "https://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe") else {
            fatalError("Invalid URL(s) when setting up DRM playback sample")
        }
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

        // create drm configuration
        let fpsConfig = FairplayConfig(license: licenseUrl, certificateURL: certificateUrl)

        // Example of how message request data can be prepared if custom modifications are needed
        fpsConfig.prepareMessage = { spcData, assetId in
            spcData
        }

        // Example of how certificate data can be prepared if custom modifications are needed
        fpsConfig.prepareCertificate = { (data: Data) -> Data in
            // Do something with the loaded certificate
            return data
        }

        // Following callbacks are available to make custom modifications:
        // - `fpsConfig.prepareCertificate`
        // - `fpsConfig.prepareLicense`
        // - `fpsConfig.prepareContentId`
        // - `fpsConfig.prepareMessage`

        // Custom request headers can be set using:
        // - `fpsConfig.certificateRequestHeaders`
        // - `fpsConfig.licenseRequestHeaders`

        // See documentation for more details.
        sourceConfig = SourceConfig(url: fairplayStreamUrl, type: .hls)
        sourceConfig.drmConfig = fpsConfig
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
