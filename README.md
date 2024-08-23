**Bitmovin Player iOS Samples**

This repository contains sample apps which are using the Bitmovin Player iOS SDK.

**Table of Contents**

- [Available Sample Apps](#available-sample-apps)
  - [Basics](#basics)
  - [DRM](#drm)
  - [Offline Playback](#offline-playback)
  - [Playback \& Casting](#playback--casting)
  - [Advertising](#advertising)
  - [UI](#ui)
  - [Playlist](#playlist)
  - [Next Up](#next-up)
  - [SharePlay](#shareplay)
  - [Analytics](#analytics)
- [Sample App Setup Instructions](#sample-app-setup-instructions)
  - [Provide License Keys](#provide-license-keys)
  - [Add the Bundle Identifier as an Allowed Domain](#add-the-bundle-identifier-as-an-allowed-domain)
- [How to integrate the Bitmovin Player iOS SDK](#how-to-integrate-the-bitmovin-player-ios-sdk)
  - [Adding the SDK To Your Project](#adding-the-sdk-to-your-project)
    - [Using CocoaPods](#using-cocoapods)
    - [Adding the SDK Directly](#adding-the-sdk-directly)
    - [Prepare your Bitmovin Player license](#prepare-your-bitmovin-player-license)
- [Development Notes](#development-notes)
  - [Casting Requirements](#casting-requirements)
- [Documentation And Release Notes](#documentation-and-release-notes)
- [Support](#support)

---

## Available Sample Apps

### Basics
+   **BasicPlayback:** Shows how to set up the Bitmovin Player for basic playback of HLS or progressive streams.
+   **BasicPlaybackTV:** Shows how to set up the Bitmovin Player for basic playback of HLS or progressive streams in a tvOS application.
+   **BasicPlaybackVisionOS:** Shows how to set up the Bitmovin Player for basic playback of HLS or progressive streams in a visionOS application.
+   **BasicMetadataHandling:** Shows how to set up and configure the Bitmovin Player for playback of content that contains metadata.
+   **BasicUIKit:** Shows how to integrate the Bitmovin Player and the Player View using UIKit.
+   **BasicUIKitTV:** Shows how to integrate the Bitmovin Player and the Player View using UIKit in a tvOS application.
+   **BasicPlaybackObjectiveC:** Shows how to set up the Bitmovin Player for basic playback of HLS or progressive streams using Objective-C.
+   **BasicPlaybackSPM:** Shows how to set up the Bitmovin Player for basic playback of HLS or progressive streams with the Swift Package Manager (SPM.)

### DRM
+   **BasicDRMPlayback:** Shows how to set up and configure the Bitmovin Player for playback of FairPlay Streaming protected content.

### Offline Playback
+   **BasicOfflinePlayback:** Shows how to set up the Bitmovin Player to download protected and unprotected content for offline playback.

### Playback & Casting
+   **BackgroundPlayback:** Shows how to set up the Bitmovin Player for background playback (e.g. to play audio in silent mode).
+   **BasicCasting:** Shows how to set up and configure Google ChromeCast support with the Bitmovin Player. (Please mind the [Casting Requirements](#casting-requirements))
+   **AdvancedCasting:** Shows how to implement advanced casting use cases. (Please mind the [Casting Requirements](#casting-requirements))

### Advertising
+   **ImaAdvertising:** Shows how to set up and configure the Bitmovin Player for playback of IMA ads.
+   **BitmovinAdvertising:** Shows how to set up and configure the Bitmovin Player for playback of BAM ads.

### UI
+   **CustomHtmlUi:** Shows how to set up and configure the Bitmovin Player to use a custom HTML UI. Besides, this sample includes how to communicate between the javascript UI and the native code.
+   **SystemUI:** Shows how to use the system UI instead of the default UI.
+   **Fullscreen:** Shows how to use the `BitmovinFullscreenHandler`-protocol to implement basic fullscreen handling.
+   **BasicPictureInPicture:** Shows how to set up and configure the Bitmovin Player to use Picture in Picture.
+   **AVPlayerViewController:** Shows how to set up and configure the Bitmovin Player to use with `AVPlayerViewController` directly.

### Playlist
+   **BasicPlaylist:** Shows how to implement queueing / playlists.
+   **BasicPlaylistTV:** Shows how to implement queueing / playlists in a tvOS application.

### Next Up
+   **NextUpTV:** Shows how to implement next-up feature in a tvOS application.

### SharePlay
+   **SharePlay:** Shows how to use the SharePlay feature to coordinate playback for multiple participants.

### Analytics
+   **Analytics:** Shows how to set up Analytics for the Bitmovin Player.

## Sample App Setup Instructions
Please execute `pod install --repo-update` to properly initialize the workspace.

### Provide License Keys
In each sample app, you also have to provide two license keys, a Bitmovin Player license key and a Bitmovin Analytics license key.

Your Bitmovin Player license key can be found when logging in into [https://bitmovin.com/dashboard](https://bitmovin.com/dashboard) and navigating to `Player -> Licenses`.
You need to provide your player license key via the `PlayerConfig.key` property, that is used when creating a `Player` instance.

Your Bitmovin Analytics license key can be found when logging in into [https://bitmovin.com/dashboard](https://bitmovin.com/dashboard) and navigating to `Analytics -> Licenses`. Refer to our samples to see how the anayltics license key is provided when creating a `Player` instance.

### Add the Bundle Identifier as an Allowed Domain

Once you have set up your project’s development team, you’ll have a unique bundle identifier. This is because the bundle identifier is based on the `DEVELOPMENT_TEAM` value.
This is the final and unique bundle identifier that you have to enter to our dashboard:

Add the following bundle identifier of the sample application ending with your unique `DEVELOPMENT_TEAM` value as an allowed domain on [https://bitmovin.com/dashboard](https://bitmovin.com/dashboard), under `Player -> Licenses` and also under `Analytics -> Licenses`.

Make sure to replace `$(DEVELOPMENT_TEAM)` with your Apple development team's ID.

    # Basics:
    com.bitmovin.player.samples.playback.basic-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.tv.playback.basic-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.visionos.playback.basic-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.playback.basicuikit-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.tv.playback.basicuikit-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.metadata.basic-$(DEVELOPMENT_TEAM)

    # DRM:
    com.bitmovin.player.samples.drm.basic-$(DEVELOPMENT_TEAM)

    # Offline Playback:
    com.bitmovin.player.samples.offline.basic-$(DEVELOPMENT_TEAM)

    # Playback & Casting:
    com.bitmovin.player.samples.playback.background-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.casting.basic-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.casting.advanced-$(DEVELOPMENT_TEAM)

    # Advertising:
    com.bitmovin.player.samples.ads.basic-$(DEVELOPMENT_TEAM)

    # UI:
    com.bitmovin.player.samples.avplayerviewcontroller-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.custom.ui.html-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.fullscreen.basic-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.pictureinpicture.basic-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.systemui-$(DEVELOPMENT_TEAM)

    # Playlist:
    com.bitmovin.player.samples.playlist.basic-$(DEVELOPMENT_TEAM)
    com.bitmovin.player.samples.tv.playlist.basic-$(DEVELOPMENT_TEAM)

    # Next Up:
    com.bitmovin.player.samples.tv.nextup-$(DEVELOPMENT_TEAM)

    # SharePlay
    com.bitmovin.player.samples.shareplay-$(DEVELOPMENT_TEAM)

    # Analytics
    com.bitmovin.player.samples.analytics-$(DEVELOPMENT_TEAM)

## How to integrate the Bitmovin Player iOS SDK
When you want to develop an own iOS application using the Bitmovin Player iOS SDK read through the following steps.

### Adding the SDK To Your Project
To add the SDK as a dependency to your project, you have two options: Using CocoaPods or adding the SDK bundle directly.

#### Using CocoaPods
1. Add `source 'https://github.com/bitmovin/cocoapod-specs.git'` to your Podfile.
1. Run `pod repo update` to add the newly added source.
1. Add `pod 'BitmovinPlayer', '3.69.0'` to your Podfile.
1. Install the pod using `pod install`.

See the `Podfile` of this repository for a full example.

#### Adding the SDK Directly
When using Xcode, go to the `General` page or your app target and add the SDK bundle (`BitmovinPlayer.xcframework`) under `Linked Frameworks and Libraries`. The latest SDK for iOS and tvOS can be downloaded [here](https://cdn.bitmovin.com/player/ios_tvos/3.69.0/BitmovinPlayer.zip).

#### Prepare your Bitmovin Player license

+   Add your Bitmovin player license key to the `Info.plist` file as `BitmovinPlayerLicenseKey`. Alternatively you can also set the license key via the `PlayerConfig.key` property when creating a `Player` instance.

    Your player license key can be found when logging in into [https://bitmovin.com/dashboard](https://bitmovin.com/dashboard) and navigating to `Player -> Licenses`.

+   Add the Bundle identifier of the iOS application which is using the SDK as an allowed domain to the Bitmovin licensing backend. This can be also done under `Player -> Licenses` when logging in into [https://dashboard.bitmovin.com](https://dashboard.bitmovin.com) with your account.

    When you do not do this, you'll get a license error when starting the application which contains the player.

## Development Notes
### Casting Requirements
* If you are using the Google Cast SDK (`BasicCasting` or `AdvancedCasting`), make sure the following requirements are met:
- Use a provisioning profile with `Access WiFi Information` enabled
- The `NSBluetoothAlwaysUsageDescription` key is set in the `info.plist`

## Documentation And Release Notes
-   You can find the latest API documentation [here](https://bitmovin.com/docs/player/api-reference/ios/ios-sdk-api-reference-v3#/player/ios/3/docs/index.html).
-   The release notes can be found [here](https://bitmovin.com/docs/player/releases/ios).

## Support
If you have any questions or issues with this SDK or its examples, or you require other technical support for our services, please login to your Bitmovin Dashboard at https://bitmovin.com/dashboard and [create a new support case](https://bitmovin.com/dashboard/support/cases/create). Our team will get back to you as soon as possible :+1:
