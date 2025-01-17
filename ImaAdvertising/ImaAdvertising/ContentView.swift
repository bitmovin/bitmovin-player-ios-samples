//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Combine
import SwiftUI

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
private let playerLicenseKey = "<PLAYER_LICENSE_KEY>"
// You can find your analytics license key on the analytics license dashboard:
// https://bitmovin.com/dashboard/analytics/licenses
private let analyticsLicenseKey = "<ANALYTICS_LICENSE_KEY>"

struct ContentView: View {
    private let player: Player
    private let playerViewConfig: PlayerViewConfig
    private var sourceConfig: SourceConfig {
        // Define needed resources
        guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")  else {
            fatalError("Invalid URL")
        }

        return SourceConfig(url: streamUrl, type: .hls)
    }

    init() {
        // Create player configuration
        let playerConfig = PlayerConfig()

        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        playerConfig.styleConfig.userInterfaceConfig = uiConfig

        // Create Advertising configuration
        let adTagVastSkippable = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=".urlWithCorrelator()
        let adTagVast1 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=".urlWithCorrelator()
        let adTagVast2 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpostonly&cmsid=496&vid=short_onecue&correlator=".urlWithCorrelator()
        
        let adSource1 = AdSource(tag: adTagVastSkippable, ofType: .ima)
        let adSource2 = AdSource(tag: adTagVast1, ofType: .ima)
        let adSource3 = AdSource(tag: adTagVast2, ofType: .ima)

        let preRoll = AdItem(adSources: [adSource1], atPosition: "pre")
        let midRoll = AdItem(adSources: [adSource2], atPosition: "20%")
        let postRoll = AdItem(adSources: [adSource3], atPosition: "post")

        let adConfig = AdvertisingConfig(schedule: [preRoll, midRoll, postRoll])
        playerConfig.advertisingConfig = adConfig

        // Set your player license key on the player configuration
        playerConfig.key = playerLicenseKey

        // Create analytics configuration with your analytics license key
        let analyticsConfig = AnalyticsConfig(licenseKey: analyticsLicenseKey)

        // Create player based on player and analytics configurations
        player = PlayerFactory.createPlayer(
            playerConfig: playerConfig,
            analytics: .enabled(
                analyticsConfig: analyticsConfig
            )
        )

        // Create player view configuration
        playerViewConfig = PlayerViewConfig()
    }

    var body: some View {
        ZStack {
            Color.black

            VideoPlayerView(
                player: player,
                playerViewConfig: playerViewConfig
            )
            .onReceive(player.events.on(PlayerEvent.self)) { (event: PlayerEvent) in
                dump(event, name: "[Player Event]", maxDepth: 1)
            }
            .onReceive(player.events.on(SourceEvent.self)) { (event: SourceEvent) in
                dump(event, name: "[Source Event]", maxDepth: 1)
            }
        }
        .padding()
        .onAppear {
            player.load(sourceConfig: sourceConfig)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    func urlWithCorrelator() -> URL {
        URL(string: String(format: "%@%d", self, Int.random(in: 0..<100000)))!
    }
}
