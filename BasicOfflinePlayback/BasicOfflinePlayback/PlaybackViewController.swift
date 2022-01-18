//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

final class PlaybackViewController: UIViewController {
    @IBOutlet weak var playerViewContainer: UIView!

    var sourceConfig: SourceConfig?
    var player: Player!
    var playerView: PlayerView!
    var reach: Reachability!
    var offlineManager = OfflineManager.sharedInstance()

    deinit {
        self.player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard var sourceConfig = sourceConfig else {
            finishWithError(title: "No Stream", message: "No stream was provided")
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let reach = appDelegate.reach else {
                finishWithError(title: "Internal error", message: "AppDelegate could not be accessed")
                return
        }

        // Store reference to reachability manager to be able to check for an existing network connection
        self.reach = reach

        // Get offline content manager for the source config
        guard let offlineContentManager = try? offlineManager.offlineContentManager(for: sourceConfig) else {
            finishWithError(title: "Internal error", message: "OfflineContentManager not found for source config")
            return
        }

        // Check the offline state of the SourceConfig to determine which action to take here
        switch offlineContentManager.offlineState {
        case .downloaded, .downloading, .suspended:
            // When device is offline, we need to check if the asset can be played offline
            if reach.currentReachabilityStatus() == NetworkStatus.NotReachable {
                /**
                Create an OfflineSourceConfig which is needed by the BitmovinPlayer in order to play offline content, and
                restrict it to the audio and subtitle tracks which are cached on disk. As a result of that, tracks which
                are not cached, does not show up as selectable in the player UI.
                */
                guard offlineContentManager.offlineState == .downloaded,
                      let offlineSourceConfig = offlineContentManager.createOfflineSourceConfig(restrictedToAssetCache: true) else {
                    finishWithError(title: "Error", message: "The device seems to be offline, but no offline content for the selected source available.")
                    return
                }
                sourceConfig = offlineSourceConfig
            } else {
                /**
                Create an OfflineSourceConfig which is needed to enable efficient playback while downloading its media
                data in the background. Since we are not offline, we do not restrict the media selection options to the
                tracks which are already cached. This way the user can select also renditions which are not downloaded
                or downloading.
                */
                if let offlineSourceConfig = offlineContentManager.createOfflineSourceConfig(restrictedToAssetCache: false) {
                    sourceConfig = offlineSourceConfig
                }
            }

        case .notDownloaded, .canceling:
            // When the sourceConfig is not available offline, we have to check if we have network connectivity before
            // continuing
            guard reach.currentReachabilityStatus() != NetworkStatus.NotReachable else {
                finishWithError(title: "Error", message: "The device seems to be offline, but no offline content for the selected source available.")
                return
            }
        }

        let config = PlayerConfig()

        player = PlayerFactory.create(playerConfig: config)
        let playerView = PlayerView(player: player, frame: CGRect.zero)

        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = playerViewContainer.bounds

        playerViewContainer.addSubview(playerView)
        playerViewContainer.bringSubviewToFront(playerView)

        self.playerView = playerView

        player.load(sourceConfig: sourceConfig)
    }

    func finishWithError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
            return
        })
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        playerView?.willRotate()
        coordinator.animate(alongsideTransition: { _ in
            let landscape = size.width > size.height
            self.navigationController?.setNavigationBarHidden(landscape, animated: true)
        }) { _ in
            self.playerView?.didRotate()
            self.setNeedsStatusBarAppearanceUpdate()
        }

        super.viewWillTransition(to: size, with: coordinator)
    }

    override var prefersStatusBarHidden: Bool {
        return UIDevice.current.orientation.isLandscape
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}

extension PlaybackViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
