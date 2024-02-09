//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Combine
import Foundation
import UIKit

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
private let playerLicenseKey = "<PLAYER_LICENSE_KEY>"
// You can find your analytics license key on the analytics license dashboard:
// https://bitmovin.com/dashboard/analytics/licenses
private let analyticsLicenseKey = "<ANALYTICS_LICENSE_KEY>"

class PlaybackViewController: UIViewController {
    @IBOutlet weak var suspendedSwitch: UIBarButtonItem!
    @IBOutlet weak var playerViewContainer: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var eligibleForGroupPlaybackWarningHeight: NSLayoutConstraint!

    var viewModel: ViewModel!
    private var player: Player!
    private var currentSuspension: SharePlaySuspension?
    private var cancellables = Set<AnyCancellable>()

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        CoordinationManager.shared.observer.$isEligibleForGroupSession
            .receive(on: RunLoop.main)
            .sink { [weak self] isEligible in
                guard let self = self else { return }

                self.handleViewState(isEligibleForGroupPlayback: isEligible)
            }
            .store(in: &cancellables)

        player = setupPlayer()
        setupPlayerView(with: player)

        guard let sourceConfig = SourceConfig.create(from: viewModel.asset) else {
            print("Could not create asset")
            return
        }

        player.load(sourceConfig: sourceConfig)
    }

    @IBAction func suspensionToggled(_ sender: UISwitch) {
        if sender.isOn {
            startSuspension()
        } else {
            endSusepension()
        }
    }
}

private extension PlaybackViewController {
    func setupPlayer() -> Player {
        // Create player configuration
        let playerConfig = PlayerConfig()

        // Set your player license key on the player configuration
        playerConfig.key = playerLicenseKey

        // Create analytics configuration with your analytics license key
        let analyticsConfig = AnalyticsConfig(licenseKey: analyticsLicenseKey)

        // Create player based on player and analytics configurations
        let player = PlayerFactory.createPlayer(
            playerConfig: playerConfig,
            analytics: .enabled(
                analyticsConfig: analyticsConfig
            )
        )
        
        player.add(listener: self)

        // Check if there is a group session to coordinate playback with.
        if let groupSession = viewModel.groupSession {
            // Coordinate playback with the active session.
            player.sharePlay.coordinate(with: groupSession)
        }

        return player
    }

    func setupPlayerView(with player: Player) {
        let playerView = PlayerView(player: player, frame: .zero)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = playerViewContainer.bounds

        playerViewContainer.addSubview(playerView)
        playerViewContainer.bringSubviewToFront(playerView)
    }

    func startSuspension() {
        currentSuspension = player.sharePlay.beginSuspension(for: .userActionRequired)
    }

    func endSusepension() {
        guard let suspension = currentSuspension else { return }

        player.sharePlay.endSuspension(suspension)
    }

    func handleViewState(isEligibleForGroupPlayback: Bool) {
        eligibleForGroupPlaybackWarningHeight.constant = isEligibleForGroupPlayback ? 0 : 40
        warningLabel.isHidden = isEligibleForGroupPlayback
        suspendedSwitch.isEnabled = isEligibleForGroupPlayback
        
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

extension PlaybackViewController: PlayerListener {
    func onSharePlayStarted(_ event: SharePlayStartedEvent, player: Player) {
        print("Player started to participate in group session")
    }

    func onSharePlayEnded(_ event: SharePlayEndedEvent, player: Player) {
        print("Player stopped to participate in group session")
    }

    func onSharePlaySuspensionStarted(_ event: SharePlaySuspensionStartedEvent, player: Player) {
        print("Suspension started")
    }

    func onSharePlaySuspensionEnded(_ event: SharePlaySuspensionEndedEvent, player: Player) {
        print("Suspension ended")
    }
}

private extension SourceConfig {
    static func create(from asset: Asset) -> SourceConfig? {
        guard let sourceConfig = SourceConfig(url: asset.url) else {
            return nil
        }

        sourceConfig.title = asset.title
        sourceConfig.posterSource = asset.posterUrl
        sourceConfig.options.sharePlayIdentifier = asset.customSharePlayIdentifier

        return sourceConfig
    }
}
