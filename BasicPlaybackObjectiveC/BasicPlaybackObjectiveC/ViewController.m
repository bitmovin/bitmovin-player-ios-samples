//
// Bitmovin Player iOS SDK
// Copyright (C) 2018, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import "ViewController.h"
#import <BitmovinPlayer/BitmovinPlayer.h>

@interface ViewController () <BMPPlayerListener>

@property (nonatomic, strong) BMPBitmovinPlayer *player;

@end

@implementation ViewController

- (void)dealloc {
    [self.player destroy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    NSURL *streamUrl = [NSURL URLWithString: @"https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"];
    NSURL *posterUrl = [NSURL URLWithString:@"https://bitmovin-a.akamaihd.net/content/MI201109210084_1/poster.jpg"];
    
    if (streamUrl == nil || posterUrl == nil){
        return;
    }
    
    // Create player configuration
    BMPPlayerConfiguration *config = [[BMPPlayerConfiguration alloc] init];
    
    BMPSourceItem *sourceItem = [[BMPSourceItem alloc] initWithUrl:streamUrl];
    
    // Set a poster image
    [sourceItem setPosterSource:posterUrl];
    
    // Set source item for configuration
    [config setSourceItem:sourceItem];
    
    // Create player based on player configuration
    BMPBitmovinPlayer *player = [[BMPBitmovinPlayer alloc] initWithConfiguration:config];
    
    // Create player view and pass the player instance to it
    BMPBitmovinPlayerView *playerView = [[BMPBitmovinPlayerView alloc]initWithPlayer:player frame:CGRectZero];
    
    // Listen to player events
    [player addPlayerListener:self];
    
    playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    playerView.frame = self.view.bounds;
    
    [self.view addSubview:playerView];
    [self.view bringSubviewToFront:playerView];
    
    self.player = player;
}

// MARK: BMPPlayerListener

- (void)onPlay:(BMPPlayEvent *)event {
    NSLog(@"onPlay: %f", event.time);
}

- (void)onPaused:(BMPPausedEvent *)event {
    NSLog(@"onPaused: %f", event.time);
}

- (void)onTimeChanged:(BMPTimeChangedEvent *)event {
    NSLog(@"onTimeChanged: %f", event.currentTime);
}

- (void)onDurationChanged:(BMPDurationChangedEvent *)event {
    NSLog(@"onDurationChanged: %f", event.duration);
}

- (void)onError:(BMPErrorEvent *)event {
    NSLog(@"onError: %@", event.message);
}

@end
