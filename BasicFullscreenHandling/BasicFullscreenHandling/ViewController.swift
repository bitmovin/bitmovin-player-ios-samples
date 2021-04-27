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
    var playerView: PlayerView!

    var orientation: UIInterfaceOrientationMask = .allButUpsideDown
    var fullscreenRequestedByOrientationChange: Bool = false

    var fullscreen: Bool = false {
        didSet {
            // Hide statusbar in fullscreen
            UIView.animate(withDuration: 0.5) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    // To have this method called correctly, the UINavigationController+Extensions are needed
    override var shouldAutorotate: Bool {
        return true
    }

    // To have this method called correctly, the UINavigationController+Extensions are needed
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation
    }

    override var prefersStatusBarHidden: Bool {
        return fullscreen
    }

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
        playerView = PlayerView(player: player, frame: .zero)

        // Set fullscreen handler
        playerView.fullscreenHandler = self

        // Listen to player events
        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds

        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        sourceConfig.posterSource = posterUrl

        player.load(sourceConfig: sourceConfig)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        playerView?.willRotate()

        let width = size.width
        let height = size.height

        // Distinguish between fullscreen requested either by touching fullscreen button or changing orientation
        self.fullscreenRequestedByOrientationChange = width > height

        coordinator.animate(alongsideTransition: { _ in
            if width > height {
                // Will enter landscape
                self.playerView?.enterFullscreen()
            } else {
                // Will enter portrait
                self.playerView?.exitFullscreen()
            }
        }) { _ in
            self.playerView?.didRotate()
        }

        super.viewWillTransition(to: size, with: coordinator)
    }
}

// MARK: - Fullscreen Handler

extension ViewController: FullscreenHandler {
    var isFullscreen: Bool {
        return fullscreen
    }

    func onFullscreenRequested() {
        updateLayoutOnFullscreenChange(fullscreen: true)
    }

    func onFullscreenExitRequested() {
        updateLayoutOnFullscreenChange(fullscreen: false)
    }

    private func updateLayoutOnFullscreenChange(fullscreen: Bool) {
        self.fullscreen = fullscreen

        // Update navigation bar
        navigationController?.setNavigationBarHidden(fullscreen, animated: true)

        if !fullscreenRequestedByOrientationChange {
            playerView?.willRotate()

            // Force orientation; this will be used when supportedInterfaceOrientation is called
            orientation = fullscreen ? .landscape : .portrait

            // Present dummy controller so that after push, supportedInterfaceOrientations is called again
            let dummy = UIViewController()
            dummy.modalPresentationStyle = .fullScreen
            navigationController?.present(dummy, animated: false) {
                dummy.dismiss(animated: false) {
                    // reset orientation
                    self.orientation = .allButUpsideDown
                    self.playerView?.didRotate()
                }
            }
        } else {
            fullscreenRequestedByOrientationChange = false
        }
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
