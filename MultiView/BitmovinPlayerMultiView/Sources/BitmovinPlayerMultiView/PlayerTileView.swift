//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import SwiftUI

internal struct PlayerTileView: View {
    let video: Video
    let showUi: Bool

    @State var cornerRadius: Double

    var body: some View {
        ZStack {
            VideoLayerView(player: video.player)

            if showUi {
                VideoPlayerView(player: video.player)
            }
        }
        .background(Color.black)
        .cornerRadius(cornerRadius)
    }
}

private struct VideoLayerView: UIViewRepresentable {
    class HostView: UIView {
        init(player: Player, frame: CGRect) {
            super.init(frame: frame)

            // Setting the video gravity to fill to not have gaps between video frames when the
            // aspect ration does not match.
            playerLayer.videoGravity = .resizeAspectFill

            player.register(playerLayer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var playerLayer: AVPlayerLayer {
            layer as! AVPlayerLayer
        }

        override class var layerClass: AnyClass {
            AVPlayerLayer.self
        }
    }

    var player: Player

    func makeUIView(context: Context) -> HostView {
        HostView(player: player, frame: .zero)
    }

    func updateUIView(_ uiView: HostView, context: Context) { }
}
