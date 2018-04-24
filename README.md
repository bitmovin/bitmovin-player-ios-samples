# bitmovin-player-ios-samples
This repository contains sample apps which are using the Bitmovin Player iOS SDK. The following sample apps are included at the moment:

+   **BasicPlayback:** Shows how the Bitmovin Player can be setup for basic playback of HLS or progressive streams.
+   **BasicPlaybackTV:** Shows how the Bitmovin Player can be setup for basic playback of HLS or progressive streams in a tvOS application.
+   **BasicDRMPlayback:** Shows how the Bitmovin Player can be setup and configured for playback of FairPlay Streaming protected content.
+   **BasicCasting** Shows how the ChromeCast support of the Bitmovin Player can be setup and configured.
+   **BasicMetadataHandling** Shows how the Bitmovin Player can be setup and configured for playback of content which contains metadata.
+   **CustomHtmlUi** Shows how the Bitmovin Player can be setup and configured to use a custom HTML UI.
+   **BasicAds** Shows how the Bitmovin Player can be setup and configured for playback of ads.
+   **AirPlay** Shows how AirPlay support can be enabled for the Bitmovin Player.
+   **SystemUI** Shows how the system UI can be used instead of Bitmovin's default UI.
+   **BasicPlaylist** Shows how to implement queueing / playlists.
+   **BasicOfflinePlayback** Shows how the Bitmovin Player can be used to download protected and unprotected content for offline playback.
+   **BackgroundPlayback** Shows how background playback can be implemented for the Bitmovin Player.

## Using The Sample Apps
Please execute `pod install` to properly initialize the workspace. In each sample app you also have to add your Bitmovin Player license key to `Info.plist` file as `BitmovinPlayerLicenseKey`.

In addition to that you have to log in to [https://dashboard.bitmovin.com](https://dashboard.bitmovin.com), where you have to add the following bundle identifier of the sample application as an allowed domain under `Player -> Licenses`:

    com.bitmovin.player.samples.playback.basic
    com.bitmovin.player.samples.tv.playback.basic
    com.bitmovin.player.samples.drm.basic
    com.bitmovin.player.samples.casting.basic
    com.bitmovin.player.samples.metadata.basic
    com.bitmovin.player.samples.custom.ui.html
    com.bitmovin.player.samples.ads.basic
    com.bitmovin.player.samples.airplay
    com.bitmovin.player.samples.systemui
    com.bitmovin.player.samples.playlist.basic
    com.bitmovin.player.samples.offline.basic
    com.bitmovin.player.samples.playback.background

## Using The Bitmovin Player iOS SDK
When you want to develop an own iOS application using the Bitmovin Player iOS SDK read through the following steps.

### Adding the SDK To Your Project
To add the SDK as a dependency to your project, you have two options: Using CocoaPods or adding the SDK bundle directly.


#### Using CocoaPods
Add `pod 'BitmovinPlayer', git: 'https://github.com/bitmovin/bitmovin-player-ios-sdk-cocoapod.git', tag: '2.8.0'` to your Podfile. After that, install the pod using `pod install`. See the `Podfile` of this repository for a full example.

#### Adding the SDK Directly
+   When using XCode, go to the `General` settings page and add the SDK bundle (`BitmovinPlayer.framework`) under `Linked Frameworks and Libraries`. The SDK bundle can be downloaded from the [release page of the GitHub repository](https://github.com/bitmovin/bitmovin-player-ios-sdk-cocoapod/releases).

### Project Setup

+   Add your Bitmovin player license key to the `Info.plist` file as `BitmovinPlayerLicenseKey`.

    Your player license key can be found when logging in into [https://dashboard.bitmovin.com](https://dashboard.bitmovin.com) and navigating to `Player -> Licenses`.

+   Add the Bundle identifier of the iOS application which is using the SDK as an allowed domain to the Bitmovin licensing backend. This can be also done under `Player -> Licenses` when logging in into [https://dashboard.bitmovin.com](https://dashboard.bitmovin.com) with your account.

    When you do not do this, you'll get a license error when starting the application which contains the player.

## Documentation And Release Notes
-   You can find the latest API documentation [here](https://bitmovin.com/ios-sdk-documentation/)
-   The release notes can be found [here](https://bitmovin.com/release-notes-ios-sdk/)
