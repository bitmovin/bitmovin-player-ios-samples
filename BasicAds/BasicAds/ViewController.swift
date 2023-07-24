//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

final class ViewController: UIViewController {
    let adTagVastSkippable = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator="
    let adTagVast1 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="
    let adTagVast2 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpostonly&cmsid=496&vid=short_onecue&correlator="
    
    var player: Player!
    
    deinit {
        player?.destroy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") else {
            return
        }
        
        // Create player configuration
        let config = PlayerConfig()

        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        config.styleConfig.userInterfaceConfig = uiConfig

        // Create Advertising configuration
        let adSource1 = AdSource(tag: urlWithCorrelator(adTag: adTagVastSkippable), ofType: .ima)
        let adSource2 = AdSource(tag: urlWithCorrelator(adTag: adTagVast1), ofType: .ima)
        let adSource3 = AdSource(tag: urlWithCorrelator(adTag: adTagVast2), ofType: .ima)
        
        let preRoll = AdItem(adSources: [adSource1], atPosition: "pre")
        let midRoll = AdItem(adSources: [adSource2], atPosition: "20%")
        let postRoll = AdItem(adSources: [adSource3], atPosition: "post")
        
        let adConfig = AdvertisingConfig(schedule: [preRoll, midRoll, postRoll])
        config.advertisingConfig = adConfig

        // Create player based on player configuration
        player = PlayerFactory.create(playerConfig: config)

        // Create player view and pass the player instance to it
        let playerView = PlayerView(player: player, frame: .zero)

        // Listen to player events
        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds

        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        player.load(sourceConfig: sourceConfig)
    }
    
    func urlWithCorrelator(adTag: String) -> URL {
        var urlString = adTag
        #if targetEnvironment(simulator)
            urlString = adTag.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed )!
        #endif
        return URL(string: String(format: "%@%d", urlString, Int(arc4random_uniform(100000))))!
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
