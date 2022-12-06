//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Combine
import Foundation
import GroupActivities

class CoordinationManager {
    static let shared = CoordinationManager()
    let observer = GroupStateObserver()
    private var cancellables = Set<AnyCancellable>()

    @Published var asset: Asset?
    @Published var groupSession: GroupSession<MediaWatchingActivity>?

    private init() {
        Task {
            // Await new sessions to watch movies together.
            for await groupSession in MediaWatchingActivity.sessions() {
                // Set the app's active group session.
                self.groupSession = groupSession
                cancellables.removeAll()

                // Observe changes to the session state.
                groupSession.$state.sink { [weak self] state in
                    if case .invalidated = state {
                        self?.groupSession = nil
                        self?.cancellables.removeAll()
                    }
                }
                .store(in: &cancellables)

                // Join the session to participate in playback coordination.
                groupSession.join()
                // Observe when the local user or a remote participant starts an activity.
                groupSession.$activity
                    // This is needed as we get called twice here with the same activity, even though we just set
                    // a new activity once and we are only subscribed once. Seems like an iOS bug.
                    .removeDuplicates {
                        $0.identifier == $1.identifier
                    }
                    .sink { [weak self] activity in
                        // Set the movie to enqueue it in the player.
                        self?.asset = activity.asset
                    }
                    .store(in: &cancellables)
            }
        }
    }

    /// When a user selects a movie, here we determine whether it needs to play the movie for the current user only, or share it with the group.
    /// It makes this determination by calling the activity’s asynchronous `prepareForActivation()` method, which enables the system
    /// to present an interface for the user to select their preferred action.
    func prepareToPlay(asset: Asset) {
        if let groupSession = groupSession,
           groupSession.state == .joined {
            if asset.customSharePlayIdentifier == groupSession.activity.asset.customSharePlayIdentifier,
               asset.url == groupSession.activity.asset.url {
                // Do not change the current activity of the group in case the same asset is selected again.
                // Here, we just set it locally for us, so that the PlaybackViewController is presented.
                self.asset = asset
            } else {
                // Create a new activity based on the selected asset so that every participant in the group can react
                // to that change.
                groupSession.activity = MediaWatchingActivity(asset: asset)
            }
            return
        }

        Task {
            // Create a new activity for the selected movie.
            let activity = MediaWatchingActivity(asset: asset)

            // Await the result of the preparation call.
            switch await activity.prepareForActivation() {
            case .activationDisabled:
                // Playback coordination isn't active, or the user prefers to play the
                // movie apart from the group. Enqueue the movie for local playback only.
                self.asset = activity.asset
            case .activationPreferred:
                // The user prefers to share this activity with the group.
                // The app enqueues the movie for playback when the activity starts.
                do {
                    _ = try await activity.activate()
                } catch {
                    print("Unable to activate the activity: \(error)")
                }
            case .cancelled:
                // The user cancels the operation. So we do nothing.
                break
            default:
                break
            }
        }
    }
}
