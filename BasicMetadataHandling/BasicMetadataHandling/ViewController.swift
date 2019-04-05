//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

final class ViewController: UIViewController {

    var player: BitmovinPlayer?

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
        guard let streamUrl = URL(string: "") else {
            print("Please specify the needed resources marked with TODO in ViewController.swift file.")
            return
        }

        // Create player configuration
        let config = PlayerConfiguration()

        do {
            try config.setSourceItem(url: streamUrl)

            // Create player based on player configuration
            let player = BitmovinPlayer(configuration: config)

            // Create player view and pass the player instance to it
            let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)

            // Listen to player events
            player.add(listener: self)

            playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerView.frame = view.bounds

            view.addSubview(playerView)
            view.bringSubviewToFront(playerView)

            self.player = player
        } catch {
            print("Configuration error: \(error)")
        }
    }
}

extension ViewController: PlayerListener {

    public func onMetadata(_ event: MetadataEvent) {
        if (event.metadataType == .ID3) {
            for entry in event.metadata.entries {
                if let metadataEntry = entry as? AVMetadataItem,
                   let id3Key = metadataEntry.key {
                    print("Received metadata with key: \(id3Key)")
                }
            }
        }
    }
}
