//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
private let playerLicenseKey = "<PLAYER_LICENSE_KEY>"
// You can find your analytics license key on the analytics license dashboard:
// https://bitmovin.com/dashboard/analytics/licenses
private let analyticsLicenseKey = "<ANALYTICS_LICENSE_KEY>"

final class ViewController: UIViewController {
    private var player: Player!

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        // Define needed resources
        guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let posterUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/MI201109210084/poster.jpg") else {
            return
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
            analytics: .enabled(analyticsConfig: analyticsConfig)
        )

        // Create player view and pass the player instance to it
        let playerView = PlayerView(player: player, frame: .zero)

        // Listen to player events
        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds

        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)

        // Create HLSSource as an HLS stream is provided
        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)

        // Set title and poster image
        sourceConfig.title = "Demo Stream"
        sourceConfig.sourceDescription = "Demo Stream"
        sourceConfig.posterSource = posterUrl

        // Provide a different SourceConfig for casting. For local playback we use a HLS stream and for casting a
        // Widevine protected DASH stream with the same content.
        playerConfig.remoteControlConfig.prepareSource = { type, sourceConfig in
            switch type {
            case .cast:
                // Create a different source for casting
                guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/art-of-motion_drm/mpds/11331.mpd"),
                      let licenseUrl = URL(string: "https://cwip-shaka-proxy.appspot.com/no_auth") else {
                    return nil
                }

                // Create DASHSource as a DASH stream is used for casting
                let castSourceConfig = SourceConfig(url: streamUrl, type: .dash)
                castSourceConfig.title = sourceConfig.title
                castSourceConfig.sourceDescription = sourceConfig.sourceDescription

                let widevineConfig = WidevineConfig(license: licenseUrl)
                castSourceConfig.drmConfig = widevineConfig

                return castSourceConfig
            @unknown default:
                return nil
            }
        }

        player.load(sourceConfig: sourceConfig)
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
