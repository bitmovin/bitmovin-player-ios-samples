//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
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
    var player: Player!
    var playerView: PlayerView!

    // stores the content proposal which should be visible once the given playback time was reached
    var pendingContentProposal: ContentProposal?

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let proposalStreamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8") else {
            return
        }

        // Create player configuration
        let playerConfig = PlayerConfig()

        // Enable auto play
        playerConfig.playbackConfig.isAutoplayEnabled = true

        // Set your player license key on the player configuration
        playerConfig.key = playerLicenseKey

        // Create analytics configuration with your analytics license key
        let analyticsConfig = AnalyticsConfig(licenseKey: analyticsLicenseKey)

        // Create player based on player and analytics configurations
        player = PlayerFactory.create(
            playerConfig: playerConfig,
            analyticsConfig: analyticsConfig
        )
        // Create player view and pass the player instance to it
        playerView = PlayerView(player: player, frame: .zero)

        // Listen to player events
        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds

        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        player.load(sourceConfig: sourceConfig)

        let proposalSource = SourceFactory.create(from: SourceConfig(url: proposalStreamUrl, type: .hls))

        pendingContentProposal = ContentProposal(
            contentTimeForTransition: 15,
            previewImage: UIImage(named: "sintel-preview")!,
            title: "Sintel",
            description: """
                    A girl named Sintel searches for a baby dragon she calls Scales. \
                    A flashback reveals that Sintel found Scales with its wing injured and helped care for it, \
                    forming a close bond with it.
                    """,
            source: proposalSource
        )
    }
}

private extension ViewController {
    /// Get content proposal for given playback time if any and removing it from `pendingContentProposal` once found.
    /// - Parameters:
    ///   - time: playback time to check
    /// - Returns: pending `ContentProposal` matching for the playback time or `nil`
    func popContentProposal(forTime time: TimeInterval) -> ContentProposal? {
        guard let contentProposal = pendingContentProposal,
              time >= contentProposal.contentTimeForTransition else {
            return nil
        }

        pendingContentProposal = nil
        return contentProposal
    }

    /// Calculate desired frame for `PlayerView` for given state
    /// - Parameters:
    ///   - collapsed: pass `true` when player should be minimized during content proposal presentation
    /// - Returns: calculated frame for `PlayerView`
    func playerViewFrame(collapsed: Bool) -> CGRect {
        if collapsed {
            return CGRect(
                x: UIScreen.main.bounds.width / 4,
                y: UIScreen.main.bounds.height / 2,
                width: UIScreen.main.bounds.width / 2,
                height: UIScreen.main.bounds.height / 2
            )
        } else {
            return CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
        }
    }

    /// Animate `PlayerView` to the target frame
    /// - Parameters:
    ///   - targetFrame: end frame for `PlayerView` after the animation
    func animatePlayerView(to targetFrame: CGRect) {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            guard let self = self else { return }

            self.playerView.frame = targetFrame
            self.view.layoutIfNeeded()
        }
    }

    /// Present content proposal once found
    /// - Parameters:
    ///   - time: current playback time or `.infinity` for checking at the end of playback
    func checkAndPresentContentProposal(forTime time: TimeInterval) {
        guard presentedViewController == nil,
              let contentProposal = popContentProposal(forTime: time) else {
            return
        }

        guard let contentProposalViewController = storyboard?.instantiateViewController(
            withIdentifier: "ContentProposalViewController"
        ) as? ContentProposalViewController else {
            return
        }

        contentProposalViewController.contentProposal = contentProposal
        contentProposalViewController.delegate = self

        let collapsedPlayerViewFrame = playerViewFrame(collapsed: true)
        animatePlayerView(to: collapsedPlayerViewFrame)
        present(contentProposalViewController, animated: true)
    }
}

extension ViewController: PlayerListener {
    func onTimeChanged(_ event: TimeChangedEvent, player: Player) {
        print("onTimeChanged \(event.currentTime)")
        checkAndPresentContentProposal(forTime: event.currentTime)
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent, player: Player) {
        print("onPlaybackFinished")
        checkAndPresentContentProposal(forTime: .infinity)
    }

    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}

extension ViewController: ContentProposalViewControllerDelegate {
    func didDismissContentProposal(
        _ contentProposal: ContentProposal,
        withAction action: ContentProposalAction,
        animated: Bool
    ) {
        switch action {
        case .accept:
            // replace currently loaded source with the source from proposal
            player.load(source: contentProposal.source)

            // in case the proposed source is part of an already loaded playlist
            // the player.playlist.seek API can be used, like this:
            //
            // > player.playlist.seek(source: contentProposal.source, time: 0)
        case .reject:
            break
        case .defer:
            // defer current content proposal to be displayed the end of playback of the current item
            var deferredContentProposal = contentProposal
            deferredContentProposal.contentTimeForTransition = .infinity
            pendingContentProposal = deferredContentProposal
        }
        let expandedPlayerViewFrame = playerViewFrame(collapsed: false)
        animatePlayerView(to: expandedPlayerViewFrame)
    }
}
