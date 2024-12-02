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

/// A coordinator that manages the selected Player instances for MultiView playback.
public class MultiViewCoordinator: ObservableObject {
    @Published private(set) var selectedItems = [Video]() {
        didSet {
            muteAll(except: selectedItems.first?.player)
        }
    }
    @Published private(set) var focusedItem: Video? {
        didSet {
            muteAll(except: focusedItem?.player)
        }
    }
    @Published var fullScreenItem: Video?
    // For now the `fourPlayerMode` is considered private. It is still included in the project for showcasing purposes.
    @Published private var fourPlayerMode: FourPlayerMode

    /// Creates a new `MultiViewCoordinator` instance.
    public convenience init() {
        self.init(fourPlayerMode: .focused)
    }

    private init(fourPlayerMode: FourPlayerMode) {
        self.fourPlayerMode = fourPlayerMode
    }

    internal var viewMode: ViewMode {
        switch (selectedItems.count, fourPlayerMode) {
        case (0, _):
            .empty
        case (1, _):
            .single(video: selectedItems[0])
        case (2, _):
            .sideBySide(first: selectedItems[0], second: selectedItems[1])
        case (3, _), (4, .focused):
            .focusedSideBar(focused: selectedItems[0], sidebar: Array(selectedItems[1..<selectedItems.count]))
        case (4, .tiled):
            .tiled(videos: selectedItems)
        case (5, _):
            .centerSideBar(left: Array(selectedItems[1..<3]), center: selectedItems[0], right: Array(selectedItems[3..<selectedItems.count]))
        default:
            .invalid
        }
    }

    /// Helper method to determine if a Player is already used in MultiView.
    public func contains(player: Player) -> Bool {
        selectedItems.contains { $0.player === player }
    }

    /// Adds the given Player to the MultiView layout.
    public func add(player: Player) {
        if !player.isMuted {
            player.mute()
        }

        let video = Video(player: player)
        toggleSelectedVideo(video)
    }

    /// Removes the given Player from the MultiView layout.
    public func remove(player: Player) {
        let video = Video(player: player)
        toggleSelectedVideo(video)
    }

    internal func swap(video: Video) {
        guard let index = selectedItems.firstIndex(of: video) else { return }

        selectedItems.swapAt(0, index)
    }

    internal func focus(video: Video?) {
        focusedItem = video
    }

    internal func toggleSelectedVideo(_ video: Video) {
        if let index = selectedItems.firstIndex(of: video) {
            selectedItems.remove(at: index)
            return
        }

        guard selectedItems.count < 5 else { return }

        selectedItems.append(video)
    }

    private func muteAll(except player: Player?) {
        selectedItems
            .map(\.player)
            .filter { !$0.isMuted }
            .filter { $0 !== player }
            .forEach { $0.mute() }

        if let player, player.isMuted {
            player.unmute()
        }
    }
}
