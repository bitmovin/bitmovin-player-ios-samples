//
// Bitmovin Player iOS SDK
// Copyright (C) 2026, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
// Pause ads are experimental. Their Swift APIs are only visible through the `ExperimentalApi` SPI
// and may change or be removed in future releases without a major version bump.
@_spi(ExperimentalApi) import BitmovinPlayerCore
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
        guard let streamUrl = URL(string: "https://cdn.bitmovin.com/content/internal/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") else {
            fatalError("Invalid URL")
        }

        return SourceConfig(url: streamUrl, type: .hls)
    }

    init() {
        // Create player configuration
        let playerConfig = PlayerConfig()

        // Pause ads require a VAST tag with a static PNG or JPEG `NonLinear` creative
        // and an `AdSource` of type `.bitmovin`.
        let pauseAdTag = "https://pubads.g.doubleclick.net/gampad/ads?sz=480x70&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dnonlinear&correlator=".urlWithCorrelator()
        let pauseAdSource = AdSource(tag: pauseAdTag, ofType: .bitmovin)

        // The `.pause` trigger makes the ad item eligible one second after content playback is paused.
        // A visible pause ad is dismissed through the UI, `player.ads.skip()`, seeking, or resuming playback.
        let pauseAd = AdItem(adSources: [pauseAdSource], trigger: .pause)

        // Pause ads can also be scheduled at runtime using `player.ads.schedule(adItem:)`.
        let adConfig = AdvertisingConfig(schedule: [pauseAd])
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
        let playerViewConfig = PlayerViewConfig()
        playerViewConfig.hideFirstFrame = true
        self.playerViewConfig = playerViewConfig
    }

    var body: some View {
        VStack {
            VideoPlayerView(
                player: player,
                playerViewConfig: playerViewConfig
            )
            .background(Color.black)
            .cornerRadius(25)
            .onReceive(player.events.on(PlayerEvent.self)) { (event: PlayerEvent) in
                dump(event, name: "[Player Event]", maxDepth: 1)
            }
            .onReceive(player.events.on(SourceEvent.self)) { (event: SourceEvent) in
                dump(event, name: "[Source Event]", maxDepth: 1)
            }
            // Observe the pause ad presentation lifecycle
            .onReceive(player.events.on(NonLinearAdStartedEvent.self)) { _ in
                print("[Pause Ad] Started")
            }
            .onReceive(player.events.on(NonLinearAdFinishedEvent.self)) { _ in
                print("[Pause Ad] Finished")
            }
            .onReceive(player.events.on(NonLinearAdSkippedEvent.self)) { _ in
                print("[Pause Ad] Skipped")
            }

            Text("Start playback, then pause it to see the pause ad.")
                .font(.footnote)
                .foregroundColor(.secondary)
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
