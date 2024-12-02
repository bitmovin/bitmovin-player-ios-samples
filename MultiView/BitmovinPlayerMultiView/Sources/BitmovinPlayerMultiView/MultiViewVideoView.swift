//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import SwiftUI

/// A View that handles the layout of multiple video players.
/// Available view modes:
/// - Empty: No video is selected
/// - Single: One video is selected
/// - SideBySide: Two videos are selected
/// - FocusedSideBar: One video is focused and multiple videos are displayed in a sidebar
/// - Tiled: Multiple videos are displayed in a 2 by 2 grid layout
/// - CenterSideBar: One video is focused and multiple videos are displayed in a sidebar on the left and on the right
public struct MultiViewPlayerView: View {
    @ObservedObject var multiViewCoordinator: MultiViewCoordinator

    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    @Namespace private var animation
#if os(tvOS)
    @FocusState private var focusedVideo: Video.ID?
#endif

    private let spacing: Double = 10
    private let cornerRadius: Double = 8

    private var isCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }

    /// Initializes a new instance of MultiViewPlayerView.
    /// - Parameter multiViewCoordinator: The coordinator that manages the selected Player instances.
    public init(multiViewCoordinator: MultiViewCoordinator) {
        self.multiViewCoordinator = multiViewCoordinator
    }

    public var body: some View {
        VStack {
            switch multiViewCoordinator.viewMode {
            case .empty:
                emptyStateView
            case .single(video: let video):
                playerTileView(video: video, showUi: true)
            case .sideBySide(first: let firstVideo, second: let secondVideo):
                sideBySideView(firstVideo: firstVideo, secondVideo: secondVideo)
            case .focusedSideBar(focused: let focusedVideo, sidebar: let sidebarVideos):
                focusedSideBarView(focusedVideo: focusedVideo, sidebarVideos: sidebarVideos)
            case .tiled(videos: let tiledVideos):
                tiledView(tiledVideos: tiledVideos)
            case .centerSideBar(left: let leftVideos, center: let focusedVideo, right: let rightVideos):
                centeredSidebarView(leftVideos: leftVideos, focusedVideo: focusedVideo, rightVideos: rightVideos)
            default:
                Text("Unsupported number of selectedItems: \(multiViewCoordinator.selectedItems.count)")
            }
        }
        .fullScreenCover(item: $multiViewCoordinator.fullScreenItem) { video in
            playerTileView(
                video: video,
                showUi: true,
                isFullScreen: true
            )
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        Text("Select a video to play")
            .font(.title.bold())
    }

    @ViewBuilder
    private func sideBySideView(firstVideo: Video, secondVideo: Video) -> some View {
        DynamicStack(spacing: spacing) {
            playerTileView(video: firstVideo, showUi: multiViewCoordinator.focusedItem == firstVideo)
                .onTapGesture {
                    multiViewCoordinator.focus(video: firstVideo)
                }
            playerTileView(video: secondVideo, showUi: multiViewCoordinator.focusedItem == secondVideo)
                .onTapGesture {
                    multiViewCoordinator.focus(video: secondVideo)
                }
        }
    }

    @ViewBuilder
    private func focusedSideBarView(focusedVideo: Video, sidebarVideos: [Video]) -> some View {
        GeometryReader { geometry in
            DynamicStack(spacing: spacing) {
                playerTileView(video: focusedVideo, showUi: true)
                DynamicStack(
                    spacing: spacing,
                    regularStackType: .vertical,
                    compactStackType: .horizontal
                ) {
                    ForEach(sidebarVideos) { video in
                        playerTileView(video: video, showUi: false)
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        withAnimation {
                                            multiViewCoordinator.swap(video: video)
                                        }
                                    },
                                including: .all
                            )
                    }
                }
                .frame(width: !isCompact ? geometry.size.width * 0.3 : geometry.size.width)
                .frame(height: isCompact ? geometry.size.height * 0.3 : geometry.size.height)
            }
        }
    }

    @ViewBuilder
    private func tiledView(tiledVideos: [Video]) -> some View {
        VStack(spacing: spacing) {
            ForEach(Array(tiledVideos.chunked(into: 2).enumerated()), id: \.offset) { _, videos in
                HStack(spacing: spacing) {
                    ForEach(videos) { video in
                        playerTileView(video: video, showUi: multiViewCoordinator.focusedItem == video)
                            .onTapGesture {
                                multiViewCoordinator.focus(video: video)
                            }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func centeredSidebarView(leftVideos: [Video], focusedVideo: Video, rightVideos: [Video]) -> some View {
        GeometryReader { geometry in
            DynamicStack(spacing: spacing) {
                DynamicStack(
                    spacing: spacing,
                    regularStackType: .vertical,
                    compactStackType: .horizontal
                ) {
                    ForEach(leftVideos) { video in
                        playerTileView(video: video, showUi: false)
                            .onTapGesture {
                                withAnimation {
                                    multiViewCoordinator.swap(video: video)
                                }
                            }
                    }
                }
                playerTileView(video: focusedVideo, showUi: true)
                    .frame(width: !isCompact ? geometry.size.width * 0.5 : geometry.size.width)
                    .frame(height: isCompact ? geometry.size.height * 0.5 : geometry.size.height)
                DynamicStack(
                    spacing: spacing,
                    regularStackType: .vertical,
                    compactStackType: .horizontal
                ) {
                    ForEach(rightVideos) { video in
                        playerTileView(video: video, showUi: false)
                            .onTapGesture {
                                withAnimation {
                                    multiViewCoordinator.swap(video: video)
                                }
                            }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func playerTileView(
        video: Video,
        showUi: Bool,
        isFullScreen: Bool = false
    ) -> some View {
        PlayerTileView(
            video: video,
            showUi: showUi,
            isFullScreen: isFullScreen,
            cornerRadius: cornerRadius
        )
        .id(video.id)
        .fillSpace()
        .matchedGeometryEffect(id: video.id, in: animation)
#if os(tvOS)
        .focusable()
        .focused($focusedVideo, equals: video.id)
        .onChange(of: focusedVideo) { _, videoId in
            let video = multiViewCoordinator.selectedItems.first { $0.id == videoId }
            multiViewCoordinator.focus(video: video)
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    .white,
                    lineWidth: multiViewCoordinator.fullScreenItem == nil && focusedVideo == video.id ? 6 : 0
                )
        )
        .animation(.easeInOut(duration: 0.2), value: focusedVideo)
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    guard showUi else {
                        return
                    }
                    withAnimation {
                        multiViewCoordinator.fullScreenItem = video
                    }
                },
            including: .all
        )
#endif
    }
}

/// Helper View which switches between VStack and HStack depending on the available space
private struct DynamicStack<Content: View>: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    var spacing: CGFloat?
    var regularStackType: Axis.Set = .horizontal
    var compactStackType: Axis.Set = .vertical
    @ViewBuilder var content: () -> Content

    var body: some View {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular):
            compactStack
        default:
            landscapeStack
        }
    }

    @ViewBuilder
    private var landscapeStack: some View {
        switch regularStackType {
        case .horizontal:
            hStack
        case .vertical:
            vStack
        default:
            vStack
        }
    }

    @ViewBuilder
    private var compactStack: some View {
        switch compactStackType {
        case .horizontal:
            hStack
        case .vertical:
            vStack
        default:
            vStack
        }
    }

    @ViewBuilder
    private var hStack: some View {
        HStack(
            spacing: spacing,
            content: content
        )
    }

    @ViewBuilder
    private var vStack: some View {
        VStack(
            spacing: spacing,
            content: content
        )
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
