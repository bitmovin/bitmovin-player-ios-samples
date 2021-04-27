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

        /**
         * TODO: Add URLs below to make this sample application work.
         */
        // Define needed resources
        guard let fairplayStreamUrl = URL(string: "https://easeltvinternal.origin.mediaservices.windows.net/5cd4d1e2-a5c3-4223-862d-cfad90074e09/ETV_BIG_BUCK_BUNNY_1_FEATURE.ism/manifest(format=m3u8-aapl)"),
              let certificateUrl = URL(string: "http://demo.suggestedtvconfig.co.uk/bitdash/fairplay.cer"),
              let licenseUrl = URL(string: "https://easeltvinternal.keydelivery.mediaservices.windows.net/FairPlay/?KID=bb216c0f-c8f7-40b7-84da-8a7525f56635") else {
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
