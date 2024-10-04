//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation

extension AssetsTableViewController {
    final class ViewModel {
        var numberOfRows: Int {
            assets.count
        }

        let sectionTitle = "Assets"
        let numberOfSections = 1
        private let assets: [Asset]
        private let artOfMotion = Asset(
            url: URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!,
            posterUrl: URL(string: "https://bitdash-a.akamaihd.net/content/art-of-motion_drm/art-of-motion_poster.jpg")!,
            title: "Art of Motion",
            customSharePlayIdentifier: "art-of-motion"
        )

        private let sportsMashup = Asset(
            url: URL(string: "https://cdn.bitmovin.com/content/sports-mashup/sports-mashup-hls/m3u8/master.m3u8")!,
            posterUrl: URL(string: "https://cdn.bitmovin.com/content/sports-mashup/poster.jpg")!,
            title: "Sports Mashup",
            customSharePlayIdentifier: "sports-mashup"
        )

        init() {
            assets = [artOfMotion, sportsMashup]
        }

        func item(for indexPath: IndexPath) -> Asset? {
            guard assets.indices.contains(indexPath.row) else {
                return nil
            }

            return assets[indexPath.row]
        }
    }
}
