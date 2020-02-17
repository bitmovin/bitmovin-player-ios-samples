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
    
    private var player: BitmovinPlayer?
    
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
        let config = PlayerConfiguration()

        // Create HLSSource as an HLS stream is provided
        let hlsSource = HLSSource(url: streamUrl)

        // Create a SourceItem
        let sourceItem = SourceItem(hlsSource: hlsSource)
        
        // Set title and poster image
        sourceItem.itemTitle = "Demo Stream"
        sourceItem.itemDescription = "Demo Stream"
        sourceItem.posterSource = posterUrl

        // Set the SourceItem on the player configuration
        config.sourceItem = sourceItem
        
        // Provide a different SourceItem for casting. For local playback we use a HLS stream and for casting a
        // Widevine protected DASH stream with the same content.
        config.remoteControlConfiguration.prepareSource = {
            (type: BMPRemoteControlType, sourceItem: SourceItem?) in

            switch type {
            case .cast:
                // Create a different source for casting
                guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/mpds/11331.mpd"),
                      let licenseUrl = URL(string: "https://widevine-proxy.appspot.com/proxy") else {
                    return nil
                }

                // Create DASHSource as a DASH stream is used for casting
                let dashSource = DASHSource(url: streamUrl)

                let castSource = SourceItem(dashSource: dashSource)
                castSource.itemTitle = sourceItem?.itemTitle
                castSource.itemDescription = sourceItem?.itemDescription

                let widevineConfig = WidevineConfiguration(license: licenseUrl)
                castSource.add(drmConfiguration: widevineConfig)

                return castSource
            }
        }
        
        // Create player based on player configuration
        let player = BitmovinPlayer(configuration: config)
        
        // Create player view and pass the player instance to it
        let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)

        // Listen to player events
        player.add(listener: self)
        
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds
        
        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)
        
        self.player = player
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
