//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation
import BitmovinPlayer

extension SamplesTableViewController {

    final class ViewModel {
        private var sections: [SourceItemSection]

        init() {
            sections = []

            let hlsSection = SourceItemSection(name: "HLS")
            sections.append(hlsSection)

            hlsSection.sourceItems.append(createArtOfMotionSourceItem())
            hlsSection.sourceItems.append(createSintelSourceItem())
            hlsSection.sourceItems.append(createAppleTestSequenceSimpleSourceItem())
            hlsSection.sourceItems.append(createAppleTestSequenceAdvancedSourceItem())
        }

        private func createArtOfMotionSourceItem() -> SourceItem {
            let sourceItem = SourceItem(url: URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!)
            sourceItem.itemTitle = "Art of Motion"
            sourceItem.itemDescription = "Single audio track"

            return sourceItem
        }

        private func createSintelSourceItem() -> SourceItem {
            let sourceItem = SourceItem(url: URL(string: "http://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
            sourceItem.itemTitle = "Sintel"
            sourceItem.itemDescription = "Multiple subtitle languages, Multiple audio tracks"

            return sourceItem
        }

        private func createAppleTestSequenceSimpleSourceItem() -> SourceItem {
            let sourceItem = SourceItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!)
            sourceItem.itemTitle = "Bipbop Simple"
            sourceItem.itemDescription = "Single audio track"
            return sourceItem
        }

        private func createAppleTestSequenceAdvancedSourceItem() -> SourceItem {
            let sourceItem = SourceItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
            sourceItem.itemTitle = "Bipbop Advanced"
            sourceItem.itemDescription = "Single audio track, multiple subtitles"
            return sourceItem
        }

        var numberOfSections: Int {
            return sections.count
        }

        func numberOfRows(in section: Int) -> Int {
            return sections[section].sourceItems.count
        }

        func sourceItemSection(for section: Int) -> SourceItemSection? {
            guard sections.indices.contains(section) else {
                return nil
            }
            return sections[section]
        }

        func item(for indexPath: IndexPath) -> SourceItem? {
            guard let sourceItemSection = self.sourceItemSection(for: indexPath.section),
                  sourceItemSection.sourceItems.indices.contains(indexPath.row) else {
                return nil
            }

            return sourceItemSection.sourceItems[indexPath.row]
        }
    }

    final class SourceItemSection {
        var name: String
        var sourceItems: [SourceItem] = []

        init(name: String) {
            self.name = name
        }
    }
}
