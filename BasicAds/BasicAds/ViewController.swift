//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

final class ViewController: UIViewController {
    let adTagVastSkippable = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator="
    let adTagVast1 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="
    let adTagVast2 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/32573358/2nd_test_ad_unit&ciu_szs=300x100&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator="
    
    var player: BitmovinPlayer?
    
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
        let config = PlayerConfiguration()
        
        // Create Advertising configuration
        let adSource1 = AdSource(tag: urlWithCorrelator(adTag: adTagVastSkippable), ofType: .IMA)
        let adSource2 = AdSource(tag: urlWithCorrelator(adTag: adTagVast1), ofType: .IMA)
        let adSource3 = AdSource(tag: urlWithCorrelator(adTag: adTagVast2), ofType: .IMA)
        
        let preRoll = AdItem(adSources: [adSource1], atPosition: "pre")
        let midRoll = AdItem(adSources: [adSource2], atPosition: "20%")
        let postRoll = AdItem(adSources: [adSource3], atPosition: "post")
        
        let adConfig = AdvertisingConfiguration(schedule: [preRoll, midRoll, postRoll])
        config.advertisingConfiguration = adConfig
        
        do {
            try config.setSourceItem(url: streamUrl)
            
            // Create player based on player configuration
            let player = BitmovinPlayer(configuration: config)
            
            // Create player view and pass the player instance to it
            let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)
            
            playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerView.frame = view.bounds
            
            view.addSubview(playerView)
            view.bringSubview(toFront: playerView)
            
            self.player = player
        } catch {
            print("Configuration error: \(error)")
        }
    }
    
    func urlWithCorrelator(adTag: String) -> URL {
        return URL(string: String(format: "%@%d", adTag, Int(arc4random_uniform(100000))))!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        player?.add(listener: self)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player?.remove(listener: self)
        super.viewWillDisappear(animated)
    }
}

extension ViewController: PlayerListener {
    
    func onAdScheduled(_ event: AdScheduledEvent) {
        print("onAdScheduled \(event.timestamp)")
    }
    
    func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        print("onAdBreakStarted \(event.timestamp)")
    }
    
    func onAdStarted(_ event: AdStartedEvent) {
        print("onAdStarted \(event.timestamp)")
    }
    
    func onAdFinished(_ event: AdFinishedEvent) {
        print("onAdFinished \(event.timestamp)")
    }
    
    func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        print("onAdBreakFinished \(event.timestamp)")
    }
    
    func onAdError(_ event: AdErrorEvent) {
        print("onAdError \(event.timestamp)")
    }
}
