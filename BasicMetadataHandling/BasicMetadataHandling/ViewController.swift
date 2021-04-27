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

        /**
         * TODO: Add URLs below to make this sample application work.
         */
        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/metadata/media.m3u8") else {
            print("Please specify the needed resources marked with TODO in ViewController.swift file.")
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

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        player.load(sourceConfig: sourceConfig)
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }

    public func onMetadata(_ event: MetadataEvent, player: Player) {
        if event.metadataType == .ID3 {
            for entry in event.metadata.entries {
                if let metadataEntry = entry as? AVMetadataItem,
                   let id3Key = metadataEntry.key {
                    print("Received metadata with key: \(id3Key)")
                }
            }
        }
    }
}
