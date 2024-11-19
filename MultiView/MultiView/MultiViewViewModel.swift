//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Combine
import Foundation

private var playerConfig: PlayerConfig {
    let config = PlayerConfig()
    config.key = "<PLAYER_LICENSE_KEY>"
    config.styleConfig.scalingMode = .zoom
#if os(iOS)
    config.remoteControlConfig.allowsAirPlay = false
    config.remoteControlConfig.isCastEnabled = false
#endif

    return config
}

class MultiViewViewModel: ObservableObject {
    private let availableSources = Sources.shortForm.map { SourceConfig(url: $0, type: .hls) }

    @Published var players: [Player] = []
    private var cancellableSet = Set<AnyCancellable>()

    init() {
        self.players = availableSources.map { sourceConfig in
            let player = PlayerFactory.create(playerConfig: playerConfig)
            player.load(sourceConfig: sourceConfig)
            return player
        }

        // Enable looping for all players
        self.players.forEach { player in
            player.events
                .on(PlaybackFinishedEvent.self)
                .receive(on: RunLoop.main)
                .sink { _ in
                    player.play()
                }
                .store(in: &cancellableSet)
        }
    }
}
