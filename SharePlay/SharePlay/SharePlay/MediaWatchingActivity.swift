//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation
import GroupActivities

/// This class defines a shareable experience in the app. It needs to extend `GroupActivity`.
/// The activity stores the movie to share with the group, and provides supporting metadata that the system displays when a user shares an activity.
/// `GroupActivity` extends `Codable`, so any data that an activity stores must also conform to `Codable`.
class MediaWatchingActivity: GroupActivity {
    // The movie to watch.
    let asset: Asset
    let identifier: String

    init(asset: Asset) {
        self.asset = asset
        self.identifier = UUID().uuidString
    }

    // Metadata that the system displays to participants.
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .watchTogether
        metadata.title = asset.title
        metadata.supportsContinuationOnTV = true

        return metadata
    }
}

struct Asset: Codable {
    let url: URL
    let posterUrl: URL
    let title: String
    let customSharePlayIdentifier: String?
}
