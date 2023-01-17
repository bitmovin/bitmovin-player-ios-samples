//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import SwiftUI

struct SwiftUIPlayerView: UIViewRepresentable {
    let player: Player
    let playerViewConfig: PlayerViewConfig

    func makeUIView(context: Context) -> PlayerView {
        PlayerView(player: player, frame: .zero, playerViewConfig: playerViewConfig)
    }

    func updateUIView(_ uiView: BitmovinPlayer.PlayerView, context: Context) { }
}
