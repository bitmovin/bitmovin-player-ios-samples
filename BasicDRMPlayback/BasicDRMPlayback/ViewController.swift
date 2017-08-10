//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

class ViewController: UIViewController {

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
        guard let fairplayStreamUrl = URL(string: ""),
              let certificateUrl = URL(string: ""),
              let licenseUrl = URL(string: "") else {
            print("Please specify the needed resources marked with TODO in ViewController.swift file.")
            return
        }
        
        // Create player configuration
        let config = PlayerConfiguration()
        
        do {
            try config.setSourceItem(url: fairplayStreamUrl)
            
            // create drm configuration
            let fpsConfig = FairplayConfiguration(license: licenseUrl, certificateURL: certificateUrl)

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

            config.sourceItem?.add(fpsConfig)
            
            // Create player based on player configuration
            let player = BitmovinPlayer(configuration: config)
            
            // Create player view and pass the player instance to it
            let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)
            
            playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerView.frame = view.bounds
            
            view.addSubview(playerView)
            view.bringSubview(toFront: playerView)

            self.player = player
        } catch {
            print("Configuration error: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // Add ViewController as event listener
        player?.add(self)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Remove ViewController as event listener
        player?.remove(self)
        super.viewWillDisappear(animated)
    }
}

extension ViewController: PlayerListener {

    func onPlay(_ event: PlayEvent) {
        print("onPlay \(event.time)")
    }

    func onPaused(_ event: PausedEvent) {
        print("onPaused \(event.time)")
    }

    func onTimeChanged(_ event: TimeChangedEvent) {
        print("onTimeChanged \(event.currentTime)")
    }

    func onDurationChanged(_ event: DurationChangedEvent) {
        print("onDurationChanged \(event.duration)")
    }

    func onError(_ event: ErrorEvent) {
        print("onError \(event.message)")
    }
}

