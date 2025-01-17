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

    fileprivate var player: Player!
    fileprivate var customMessageHandler: CustomMessageHandler?

    @IBOutlet fileprivate weak var playerContainerView: UIView!

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Define needed resources
        guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") else {
            return
        }

        /**
         * Go to https://github.com/bitmovin/bitmovin-player-ui to get started with creating a custom player UI.
         */
        guard let cssURL = Bundle.main.url(forResource: "bitmovinplayer-ui", withExtension: "min.css"),
              let jsURL = Bundle.main.url(forResource: "bitmovinplayer-ui", withExtension: "min.js") else {
            print("Please specify the needed resources marked with TODO in ViewController.swift file.")
            return
        }

        // Create player configuration
        let playerConfig = PlayerConfig()

        playerConfig.styleConfig.playerUiCss = cssURL
        playerConfig.styleConfig.playerUiJs = jsURL
        playerConfig.styleConfig.userInterfaceConfig = bitmovinUserInterfaceConfig

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

        // Create player view and pass the player instance to it
        let playerView = PlayerView(player: player, frame: .zero)

        // Listen to player events
        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = playerContainerView.bounds

        playerContainerView.addSubview(playerView)
        playerContainerView.bringSubviewToFront(playerView)

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        player.load(sourceConfig: sourceConfig)
    }

    @IBAction fileprivate func toggleCloseButton(_ sender: Any) {
        // Use the configured customMessageHandler to send messages to the UI
        customMessageHandler?.sendMessage("toggleCloseButton")
    }

    fileprivate var bitmovinUserInterfaceConfig: BitmovinUserInterfaceConfig {
        // Configure the JS <> Native communication
        let bitmovinUserInterfaceConfig = BitmovinUserInterfaceConfig()
        // Create an instance of the custom message handler
        customMessageHandler = CustomMessageHandler()
        customMessageHandler?.delegate = self
        bitmovinUserInterfaceConfig.customMessageHandler = customMessageHandler
        return bitmovinUserInterfaceConfig
    }
}

// MARK: - CustomMessageHandlerDelegate
extension ViewController: CustomMessageHandlerDelegate {
    func receivedSynchronousMessage(_ message: String, withData data: String?) -> String? {
        if message == "closePlayer" {
            dismiss(animated: true, completion: nil)
        }

        return nil
    }

    func receivedAsynchronousMessage(_ message: String, withData data: String?) {
        print("received Asynchronouse Messagse", message, data ?? "")
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
