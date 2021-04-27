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
    var player: Player!

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") else {
            return
        }

        // Create player configuration
        let config = PlayerConfig()

        // Enable auto play
        config.playbackConfig.isAutoplayEnabled = true

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

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        player.load(sourceConfig: sourceConfig)
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
