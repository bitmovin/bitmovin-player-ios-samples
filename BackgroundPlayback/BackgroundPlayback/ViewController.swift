//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer
import MediaPlayer

final class ViewController: UIViewController {

    var player: Player?
    var nowPlayingInfo: [String: Any] = [:]

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
              let posterUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/poster.jpg") else {
            return
        }

        // Create player configuration
        let config = PlayerConfiguration()

        do {
            try config.setSourceItem(url: streamUrl)

            config.sourceItem?.itemTitle = "Art Of Motion"
            config.sourceItem?.posterSource = posterUrl
            
            // Enable background playback for the BitmovinPlayer
            config.playbackConfiguration.isBackgroundPlaybackEnabled = true

            // Create player based on player configuration
            let player = Player(configuration: config)

            // Create player view and pass the player instance to it
            let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)

            // Listen to player events
            player.add(listener: self)

            playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerView.frame = view.bounds

            view.addSubview(playerView)
            view.bringSubviewToFront(playerView)

            self.player = player

            // Setup remote control commands to be able to control playback from Control Center
            setupRemoteTransportControls()

            // Set playback metadata. Updates to the other metadata values are done in the specific listeners
            setupNowPlayingMetadata(imageUrl: posterUrl, sourceItem: config.sourceItem)
        } catch {
            print("Configuration error: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Make sure that the correct audio session category is set to allow for background playback.
        handleAudioSessionCategorySetting()
    }

    /* Set AVAudioSessionCategoryPlayback category on the audio session. This category indicates that audio playback
    is a central feature of your app. When you specify this category, your app’s audio continues with the Ring/Silent
    switch set to silent mode (iOS only). With this category, your app can also play background audio if you're
    using the Audio, AirPlay, and Picture in Picture background mode. To enable this mode, under the Capabilities
    tab in your XCode project, set the Background Modes switch to ON and select the “Audio, AirPlay, and Picture in
    Picture” option under the list of available modes. */
    func handleAudioSessionCategorySetting() {
        let audioSession = AVAudioSession.sharedInstance()

        // When AVAudioSessionCategoryPlayback is already active, we have nothing to do here
        guard audioSession.category.rawValue != AVAudioSession.Category.playback.rawValue else { return }

        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }

    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            guard let player = self.player else { return .commandFailed }

            player.play()
            if (player.isPlaying) {
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            guard let player = self.player else { return .commandFailed }

            player.pause()
            if (player.isPaused) {
                return .success
            }
            return .commandFailed
        }
    }

    func setupNowPlayingMetadata(imageUrl: URL, sourceItem: SourceItem?) {
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  200 ... 299 ~= httpResponse.statusCode,
                  let imageData = data,
                  let image = UIImage(data: imageData) else { return }
            
            let mediaItemArtwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            
            DispatchQueue.main.async {
                self.updateNowPlayingMetadata(key: MPMediaItemPropertyArtwork, value: mediaItemArtwork)
            }
        }.resume()

        updateNowPlayingMetadata(key: MPMediaItemPropertyTitle, value: sourceItem?.itemTitle ?? "No Title")
    }

    func updateNowPlayingMetadata(key: String, value: Any) {
        nowPlayingInfo[key] = value
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

/* Listener for player events */
extension ViewController: PlayerListener {

    func onTimeChanged(_ event: TimeChangedEvent) {
        updateNowPlayingMetadata(key: MPNowPlayingInfoPropertyElapsedPlaybackTime, value: event.currentTime)
    }

    func onDurationChanged(_ event: DurationChangedEvent) {
        updateNowPlayingMetadata(key: MPMediaItemPropertyPlaybackDuration, value: event.duration)
    }
}
