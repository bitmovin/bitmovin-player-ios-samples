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

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        // Create player configuration
        let config = PlayerConfig()

        // Enable auto play
        config.playbackConfig.isAutoplayEnabled = true

        // Create player based on player configuration
        player = PlayerFactory.create(playerConfig: config)

        // Create player view and pass the player instance to it
        let playerView = PlayerView(player: player, frame: .zero)

        // Listen to player events
        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds

        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)

        let sources = createPlaylist()

        // Configure playlist-specific options
        let playlistOptions = PlaylistOptions(preloadAllSources: false)

        // Create a playlist configuration containing the playlist items (sources) and the playlist options
        let playlistConfig = PlaylistConfig(
            sources: sources,
            options: playlistOptions
        )

        // Load the playlist configuration into the player instance
        player.load(playlistConfig: playlistConfig)
    }

    func createPlaylist() -> [Source] {
        var sources = [Source]()

        guard
            let streamUrl1 = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
            let streamUrl2 = URL(string: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
        else {
            return sources
        }

        let firstSourceConfig = SourceConfig(url: streamUrl1, type: .hls)
        firstSourceConfig.title = "Art of Motion"
        let firstSource = SourceFactory.create(from: firstSourceConfig)
        // Listen to events from this source
        firstSource.add(listener: self)
        sources.append(firstSource)

        let secondSourceConfig = SourceConfig(url: streamUrl2, type: .hls)
        secondSourceConfig.title = "Sintel"
        let secondSource = SourceFactory.create(from: secondSourceConfig)
        // Listen to events from this source
        secondSource.add(listener: self)
        sources.append(secondSource)

        return sources
    }
}

extension ViewController: SourceListener {
    func onEvent(_ event: SourceEvent, source: Source) {
        let sourceIdentifier = source.sourceConfig.title ?? source.sourceConfig.url.absoluteString
        dump(event, name: "[Source Event] - \(sourceIdentifier)", maxDepth: 1)
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
