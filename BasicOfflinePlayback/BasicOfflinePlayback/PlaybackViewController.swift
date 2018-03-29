//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

final class PlaybackViewController: UIViewController {

    @IBOutlet weak var playerViewContainer: UIView!

    var sourceItem: SourceItem?
    var player: BitmovinPlayer?
    var playerView: BMPBitmovinPlayerView?
    var reach: Reachability!
    var offlineManager = OfflineManager.sharedInstance()

    deinit {
        self.player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard var sourceItem = sourceItem else {
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

        // Check the offline state of the sourceItem to determine which action to take here
        switch offlineManager.offlineState(for: sourceItem) {
        case .downloaded, .downloading, .suspended:
            // When device is offline, we need to check if the asset can be played offline
            if reach.currentReachabilityStatus() == NetworkStatus.NotReachable {
                /**
                Create an OfflineSourceItem which is needed by the BitmovinPlayer in order to play offline content, and
                restrict it to the audio and subtitle tracks which are cached on disk. As a result of that, tracks which
                are not cached, does not show up as selectable in the player UI.
                */
                guard offlineManager.isPlayableOffline(sourceItem: sourceItem),
                      let offlineSourceItem = offlineManager.createOfflineSourceItem(for: sourceItem, restrictedToAssetCache: true) else {
                    finishWithError(title: "Error", message: "The device seems to be offline, but no offline content for the selected source available.")
                    return
                }
                sourceItem = offlineSourceItem
            } else {
                /**
                Create an OfflineSourceItem which is needed to enable efficient playback while downloading its media
                data in the background. Since we are not offline, we do not restrict the media selection options to the
                tracks which are already cached. This way the user can select also renditions which are not downloaded
                or downloading.
                */
                if let offlineSourceItem = offlineManager.createOfflineSourceItem(for: sourceItem, restrictedToAssetCache: false) {
                    sourceItem = offlineSourceItem
                }
            }

        case .notDownloaded, .canceling:
            // When the sourceItem is not available offline, we have to check if we have network connectivity before
            // continuing
            guard reach.currentReachabilityStatus() != NetworkStatus.NotReachable else {
                finishWithError(title: "Error", message: "The device seems to be offline, but no offline content for the selected source available.")
                return
            }
        }

        let config = PlayerConfiguration()
        config.sourceItem = sourceItem

        let player = BitmovinPlayer(configuration: config)
        let playerView = BMPBitmovinPlayerView(player: player, frame: CGRect.zero)

        player.add(listener: self)
        playerView.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = playerViewContainer.bounds

        playerViewContainer.addSubview(playerView)
        playerViewContainer.bringSubview(toFront: playerView)

        self.playerView = playerView
        self.player = player
    }

    func finishWithError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
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
        return UIDeviceOrientationIsLandscape(UIDevice.current.orientation)
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}

// MARK: PlayerListener
extension PlaybackViewController: PlayerListener {
    
    // Implement PlayerListener methods here if needed
}

// MARK: UserInterfaceListener
extension PlaybackViewController: UserInterfaceListener {
    
    // Implement UserInterfaceListener methods here if needed
}
