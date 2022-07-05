//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

class ViewController: UIViewController {
    var player: Player!

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        // Define needed resources
        guard let fairplayStreamUrl = URL(string: "https://fps.ezdrm.com/demo/video/ezdrm.m3u8"),
              let certificateUrl = URL(string: "https://fps.ezdrm.com/demo/video/eleisure.cer"),
              let licenseUrl = URL(string: "https://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe") else {
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

        /**
         * Following callbacks are available to make custom modifications:
         * fpsConfig.prepareCertificate
         * fpsConfig.prepareLicense
         * fpsConfig.prepareContentId
         * fpsConfig.prepareMessage
         *
         * Custom request headers can be set using:
         * fpsConfig.certificateRequestHeaders
         * fpsConfig.licenseRequestHeaders
         *
         * See header documentation for more details!
         */
        let sourceConfig = SourceConfig(url: fairplayStreamUrl, type: .hls)
        sourceConfig.drmConfig = fpsConfig

        player.load(sourceConfig: sourceConfig)
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
