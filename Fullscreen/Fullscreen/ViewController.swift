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
    @IBOutlet private weak var playerHolderView: UIView!

    // default constraints
    @IBOutlet private weak var pvLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pvTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pvRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pvBottomConstraint: NSLayoutConstraint!
    // fullscreen constraints
    @IBOutlet private weak var pvFullScreenLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pvFullScreenTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pvFullScreenRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pvFullScreenBottomConstraint: NSLayoutConstraint!

    var player: Player!
    var playerView: PlayerView!

    var fullscreen: Bool = false {
        didSet {
            // Hide statusbar in fullscreen
            UIView.animate(withDuration: 0.5) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        fullscreen
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        fullscreen
    }

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Define needed resources
        guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let posterUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/MI201109210084/poster.jpg") else {
            return
        }

        // Create player configuration
        let playerConfig = PlayerConfig()

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
        playerView = PlayerView(player: player, frame: .zero)

        // Set fullscreen handler
        playerView.fullscreenHandler = self

        // Listen to player events
        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = playerHolderView.bounds

        playerHolderView.addSubview(playerView)
        playerHolderView.bringSubviewToFront(playerView)

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        sourceConfig.posterSource = posterUrl

        player.load(sourceConfig: sourceConfig)
    }
}

// MARK: - Fullscreen Handler

extension ViewController: FullscreenHandler {
    var isFullscreen: Bool {
        fullscreen
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

        // Switch layout constraints
        self.pvLeftConstraint.isActive = !fullscreen
        self.pvBottomConstraint.isActive = !fullscreen
        self.pvRightConstraint.isActive = !fullscreen
        self.pvTopConstraint.isActive = !fullscreen

        self.pvFullScreenTopConstraint.isActive = fullscreen
        self.pvFullScreenRightConstraint.isActive = fullscreen
        self.pvFullScreenBottomConstraint.isActive = fullscreen
        self.pvFullScreenLeftConstraint.isActive = fullscreen
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
