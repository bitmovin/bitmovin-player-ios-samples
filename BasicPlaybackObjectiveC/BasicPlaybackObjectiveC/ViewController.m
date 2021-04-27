//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import "ViewController.h"
#import <BitmovinPlayer/BitmovinPlayer.h>

@interface ViewController () <BMPPlayerListener>
@property (nonatomic, strong) id<BMPPlayer> player;
@end

@implementation ViewController

- (void)dealloc {
    [self.player destroy];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.blackColor;

    NSURL *streamUrl = [NSURL URLWithString:@"https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"];
    NSURL *posterUrl = [NSURL URLWithString:@"https://bitmovin-a.akamaihd.net/content/MI201109210084_1/poster.jpg"];

    if (streamUrl == nil || posterUrl == nil) {
        return;
    }

    // Create player configuration
    BMPPlayerConfig *config = [BMPPlayerConfig new];

    // Create player based on player configuration
    self.player = [BMPPlayerFactory createWithPlayerConfig:config];

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
