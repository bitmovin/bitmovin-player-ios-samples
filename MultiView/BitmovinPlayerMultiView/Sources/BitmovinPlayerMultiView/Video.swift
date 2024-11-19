//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

internal struct Video: Identifiable, Equatable {
    var id: ObjectIdentifier {
        ObjectIdentifier(player)
    }

    let player: Player

    static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.player === rhs.player
    }
}
