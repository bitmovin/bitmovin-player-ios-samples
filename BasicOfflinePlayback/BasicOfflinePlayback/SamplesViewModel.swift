//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation
import BitmovinPlayer

extension SamplesTableViewController {

    final class ViewModel {
        private var sections: [SourceConfigSection]

        init() {
            sections = []

            let hlsSection = SourceConfigSection(name: "HLS")
            sections.append(hlsSection)

            hlsSection.sourceConfigs.append(createArtOfMotionSourceConfig())
            hlsSection.sourceConfigs.append(createSportsMashupSourceConfig())
            hlsSection.sourceConfigs.append(createAppleTestSequenceSimpleSourceConfig())
            hlsSection.sourceConfigs.append(createAppleTestSequenceAdvancedSourceConfig())
        }

        private func createArtOfMotionSourceConfig() -> SourceConfig {
            let sourceUrl = URL(string: "https://cdn.bitmovin.com/content/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
            let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)
            
            sourceConfig.title = "Art of Motion"
            sourceConfig.sourceDescription = "Single audio track"
            sourceConfig.posterSource = URL(string: "https://cdn.bitmovin.com/content/assets/art-of-motion_drm/art-of-motion_poster.jpg")!

            return sourceConfig
        }

        private func createSportsMashupSourceConfig() -> SourceConfig {
            let sourceUrl = URL(string: "https://cdn.bitmovin.com/content/sports-mashup/sports-mashup-hls/m3u8/master.m3u8")!
            let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)
            
            sourceConfig.title = "Sports Mashup"
            sourceConfig.sourceDescription = "Single audio track"
            sourceConfig.posterSource = URL(string: "https://cdn.bitmovin.com/content/sports-mashup/poster.jpg")!

            return sourceConfig
        }

        private func createAppleTestSequenceSimpleSourceConfig() -> SourceConfig {
            let sourceUrl = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!
            let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)
            
            sourceConfig.title = "Bipbop Simple"
            sourceConfig.sourceDescription = "Single audio track"
            return sourceConfig
        }

        private func createAppleTestSequenceAdvancedSourceConfig() -> SourceConfig {
            let sourceUrl = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
            let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)

            sourceConfig.title = "Bipbop Advanced"
            sourceConfig.sourceDescription = "Single audio track, multiple subtitles"
            return sourceConfig
        }

        var numberOfSections: Int {
            return sections.count
        }

        func numberOfRows(in section: Int) -> Int {
            return sections[section].sourceConfigs.count
        }

        func sourceConfigSection(for section: Int) -> SourceConfigSection? {
            guard sections.indices.contains(section) else {
                return nil
            }
            return sections[section]
        }

        func item(for indexPath: IndexPath) -> SourceConfig? {
            guard let sourceConfigSection = self.sourceConfigSection(for: indexPath.section),
                  sourceConfigSection.sourceConfigs.indices.contains(indexPath.row) else {
                return nil
            }

            return sourceConfigSection.sourceConfigs[indexPath.row]
        }
    }

    final class SourceConfigSection {
        var name: String
        var sourceConfigs: [SourceConfig] = []

        init(name: String) {
            self.name = name
        }
    }
}
