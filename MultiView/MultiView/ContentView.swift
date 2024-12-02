//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import BitmovinPlayerMultiView
import Combine
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MultiViewViewModel()
    @StateObject var multiViewCoordinator = MultiViewCoordinator()

    @State private var showMultiViewPicker = true

    var body: some View {
        VStack {
            Spacer()

            MultiViewPlayerView(multiViewCoordinator: multiViewCoordinator)

            Spacer()

            togglePlayerPickerViewButton

            if showMultiViewPicker {
                playerPickerView
            }
        }
#if !os(tvOS)
        .padding()
#endif
    }

    @ViewBuilder
    private var togglePlayerPickerViewButton: some View {
        HStack {
            Button {
                withAnimation {
                    showMultiViewPicker.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "rectangle.grid.2x2.fill")
                    Text("Select Assets")
                }
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var playerPickerView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(viewModel.players.enumerated()), id: \.offset) { _, player in
                    Button {
                        withAnimation {
                            guard multiViewCoordinator.contains(player: player) else {
                                multiViewCoordinator.add(player: player)
                                player.play()
                                return
                            }

                            multiViewCoordinator.remove(player: player)
                            player.pause()
                        }
                    } label: {
                        playerPreviewView(player: player)
                    }
                }
            }
        }
#if os(tvOS)
        .scrollClipDisabled()
#endif
    }

    @ViewBuilder
    private func playerPreviewView(player: Player) -> some View {
        ZStack {
            PreviewPlayerView(player: player)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: multiViewCoordinator.contains(player: player) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .frame(maxHeight: 80)
        .aspectRatio(16/9, contentMode: .fit)
        .cornerRadius(8)
    }
}

// Helper View to render video frames without UI
private struct PreviewPlayerView: View {
    struct VideoLayerView: UIViewRepresentable {
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

    let player: Player

    var body: some View {
        VideoLayerView(player: player)
    }
}

#Preview {
    ContentView()
}
