//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation
import GroupActivities

extension PlaybackViewController {
    struct ViewModel {
        let groupSession: GroupSession<MediaWatchingActivity>?
        let asset: Asset
    }
}
