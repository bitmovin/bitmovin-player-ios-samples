//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

final class ViewController: UIViewController {
    private var player: Player!

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
            let posterUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/poster.jpg") else {
                return
        }

        // Create player configuration
        let config = PlayerConfig()

        // Create player based on player configuration
        player = PlayerFactory.create(playerConfig: config)

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
        config.remoteControlConfig.prepareSource = { type, sourceConfig in
            switch type {
            case .cast:
                // Create a different source for casting
                guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/mpds/11331.mpd"),
                      let licenseUrl = URL(string: "https://widevine-proxy.appspot.com/proxy") else {
                    return nil
                }

                // Create DASHSource as a DASH stream is used for casting
                let castSourceConfig = SourceConfig(url: streamUrl, type: .dash)
                castSourceConfig.title = sourceConfig.title
                castSourceConfig.sourceDescription = sourceConfig.sourceDescription

                let widevineConfig = WidevineConfig(license: licenseUrl)
                castSourceConfig.drmConfig = widevineConfig

                return castSourceConfig
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
