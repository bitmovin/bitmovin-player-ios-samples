//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import "ViewController.h"
#import <BitmovinPlayerCore/BitmovinPlayerCore.h>
#import <BitmovinPlayerAnalytics/BitmovinPlayerAnalytics.h>
#import <CoreCollector/CoreCollector-Swift.h>

@interface ViewController () <BMPPlayerListener>
@property (nonatomic, strong) id<BMPPlayer> player;
@end

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
static NSString *const playerLicenseKey = @"<PLAYER_LICENSE_KEY>";
// You can find your analytics license key on the analytics license dashboard:
// https://bitmovin.com/dashboard/analytics/licenses
static NSString *const analyticsLicenseKey = @"<ANALYTICS_LICENSE_KEY>";

@implementation ViewController

- (void)dealloc {
    [self.player destroy];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.blackColor;

    NSURL *streamUrl = [NSURL URLWithString:@"https://cdn.bitmovin.com/content/assets/MI201109210084/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"];
    NSURL *posterUrl = [NSURL URLWithString:@"https://cdn.bitmovin.com/content/assets/MI201109210084/poster.jpg"];

    if (streamUrl == nil || posterUrl == nil) {
        return;
    }

    // Create player configuration
    BMPPlayerConfig *playerConfig = [BMPPlayerConfig new];

    // Set your player license key on the player configuration
    playerConfig.key = playerLicenseKey;

    // Create analytics configuration with your analytics license key
    BMAAnalyticsConfig *analyticsConfig = [[BMAAnalyticsConfig alloc] initWithLicenseKey:analyticsLicenseKey];

    // Create player based on player and analytics configurations
    self.player = [BMPPlayerFactory createPlayerWithPlayerConfig:playerConfig
                                                       analytics:[BMPAnalyticsPlayerConfig enabledWithAnalyticsConfig:analyticsConfig]];

    // Create player view and pass the player instance to it
    BMPPlayerView *playerView = [[BMPPlayerView alloc] initWithPlayer:self.player frame:CGRectZero];

    // Listen to player events
    [self.player addPlayerListener:self];

    playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    playerView.frame = self.view.bounds;

    [self.view addSubview:playerView];
    [self.view bringSubviewToFront:playerView];

    BMPSourceConfig *sourceConfig = [[BMPSourceConfig alloc] initWithUrl:streamUrl type: BMPSourceTypeHls];

    // Set a poster image
    [sourceConfig setPosterSource:posterUrl];

    [self.player loadSourceConfig:sourceConfig];
}

// MARK: BMPPlayerListener
- (void)onEvent:(id<BMPEvent>)event player:(id<BMPPlayer>)player {
    NSLog(@"[Player Event]: %@", event.name);
}

@end
