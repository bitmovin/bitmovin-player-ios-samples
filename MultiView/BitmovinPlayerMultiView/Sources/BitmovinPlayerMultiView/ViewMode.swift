//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation

internal enum ViewMode {
    case single(video: Video)
    case sideBySide(first: Video, second: Video)
    case focusedSideBar(focused: Video, sidebar: [Video])
    case tiled(videos: [Video])
    case centerSideBar(left: [Video], center: Video, right: [Video])
    case invalid
    case empty
}

internal extension ViewMode {
    var tiled: Bool {
        if case .tiled = self {
            return true
        }

        return false
    }
}
