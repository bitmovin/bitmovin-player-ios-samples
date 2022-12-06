//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit

final class ItemCell: UITableViewCell {
    static let identifier = "ItemCell"

    var asset: Asset? {
        didSet {
            textLabel?.text = asset?.title
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
    }
}
