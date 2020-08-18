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

    fileprivate var player: Player?
    fileprivate var customMessageHandler: CustomMessageHandler?

    @IBOutlet fileprivate weak var playerContainerView: UIView!

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") else {
            return
        }

        // Create player configuration
        let config = PlayerConfiguration()

        /**
         * Go to https://github.com/bitmovin/bitmovin-player-ui to get started with creating a custom player UI.
         */
        guard let cssURL = Bundle.main.url(forResource: "bitmovinplayer-ui", withExtension: "min.css"),
              let jsURL = Bundle.main.url(forResource: "bitmovinplayer-ui", withExtension: "min.js") else {
            print("Please specify the needed resources marked with TODO in ViewController.swift file.")
            return
        }
        config.styleConfiguration.playerUiCss = cssURL
        config.styleConfiguration.playerUiJs = jsURL

        config.styleConfiguration.userInterfaceConfiguration = bitmovinUserInterfaceConfiguration

        do {
            try config.setSourceItem(url: streamUrl)

            // Create player based on player configuration
            let player = Player(configuration: config)

            // Create player view and pass the player instance to it
            let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)

            // Listen to player events
            player.add(listener: self)

            playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerView.frame = playerContainerView.bounds

            playerContainerView.addSubview(playerView)
            playerContainerView.bringSubviewToFront(playerView)

            self.player = player
        } catch {
            print("Configuration error: \(error)")
        }
    }

    @IBAction fileprivate func toggleCloseButton(_ sender: Any) {
        // Use the configured customMessageHandler to send messages to the UI
        customMessageHandler?.sendMessage("toggleCloseButton")
    }

    fileprivate var bitmovinUserInterfaceConfiguration: BitmovinUserInterfaceConfiguration {
        // Configure the JS <> Native communication
        let bitmovinUserInterfaceConfiguration = BitmovinUserInterfaceConfiguration()
        // Create an instance of the custom message handler
        customMessageHandler = CustomMessageHandler()
        customMessageHandler?.delegate = self
        bitmovinUserInterfaceConfiguration.customMessageHandler = customMessageHandler
        return bitmovinUserInterfaceConfiguration
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

// MARK: - PlayerListener
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

