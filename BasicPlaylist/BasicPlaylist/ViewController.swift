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
    
    var player: BitmovinPlayer?
    // Stores the index of the next playlist item to be played
    var nextPlaylistItem = 0;
    // Holds all items of the playlist
    var playlist: [PlaylistItem] = []
    var lastItemFinished = false
    var playlistStarted = false
    
    deinit {
        player?.destroy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        // Define needed resources
        guard let stream1 = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let stream2 = URL(string: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8") else {
            return
        }
        
        // Add playlist items based on the stream URL's defined above
        playlist.append(PlaylistItem(url: stream1, title: "Art of Motion", type: .HLS))
        playlist.append(PlaylistItem(url: stream2, title: "Sintel", type: .HLS))
        
        // Create player based with a default configuration
        let player = BitmovinPlayer()
        
        // Create player view and pass the player instance to it
        let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)

        // Listen to player events
        player.add(listener: self)
        
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds
        
        view.addSubview(playerView)
        view.bringSubview(toFront: playerView)
        
        // store the reference to the player
        self.player = player
        
        // Start the playlist
        playNextItem()
    }
    
    /**
     Plays the next playlist item in the playlist.
    */
    func playNextItem() -> Void {
        // check if there are unplayed items in the playlist
        if (nextPlaylistItem < playlist.count) {
            // fetch the next item to play from the playlist
            let itemToPlay = playlist[nextPlaylistItem]
            nextPlaylistItem += 1

            // Create sourceItem from type
            var sourceItem: SourceItem?

            if (itemToPlay.type == .HLS) {
                sourceItem = SourceItem(hlsSource: HLSSource(url: itemToPlay.url))
            } else if (itemToPlay.type == .progressive) {
                sourceItem = SourceItem(progressiveSource: ProgressiveSource(url: itemToPlay.url))
            } else {
                print("Source type not supported")
            }

            if let source = sourceItem {
                // Set title
                source.itemTitle = itemToPlay.title

                // Create a source configuration and add the sourceItem
                let sourceConfig = SourceConfiguration()
                sourceConfig.addSourceItem(item: source)

                // load the new source configuration
                player?.load(sourceConfiguration: sourceConfig)
            }
        }
    }
}

extension ViewController: PlayerListener {
    
    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        // Automatically play next item in the playlist if there are still unplayed items left
        lastItemFinished = nextPlaylistItem >= playlist.count
        if (!lastItemFinished) {
            playNextItem()
        }
    }
    
    func onReady(_ event: ReadyEvent) {
        // Autoplay all playlist items after the initial playlist item was started by either tapping the
        // play button or by issuing the player.play() API call.
        if (playlistStarted) {
            player?.play()
        }
    }
    
    func onPlay(_ event: PlayEvent) {
        // Remember that the playlist was started by the user
        playlistStarted = true
        
        // When the replay button in the UI was tapped or a player.play() API call was issued after the last
        // playlist item has finished, we repeat the whole playlist instead of just repeating the last item
        if (lastItemFinished) {
            // Unload the last played item and reset the playlist state
            player?.unload()
            lastItemFinished = false
            nextPlaylistItem = 0
            // Restart playlist with first item in list
            playNextItem()
        }
    }
}

// A simple struct defining a playlist item
struct PlaylistItem {
    let url: URL
    let title: String
    let type: BMPMediaSourceType
    
    init(url: URL, title: String, type: BMPMediaSourceType) {
        self.url = url
        self.title = title
        self.type = type
    }
}
