platform :ios, '14.0'
use_frameworks!

source 'https://cdn.cocoapods.org'
source 'https://github.com/bitmovin/cocoapod-specs.git'

workspace 'BitmovinPlayerSamples'

def bitmovin_player
  pod 'BitmovinPlayer', '3.67.0'
end

def google_cast
  pod 'google-cast-sdk', '4.8.1'
end

target 'BasicPlayback' do
    project 'BasicPlayback/BasicPlayback.xcodeproj'
    bitmovin_player
end

target 'BasicPlaybackObjectiveC' do
    project 'BasicPlaybackObjectiveC/BasicPlaybackObjectiveC.xcodeproj'
    bitmovin_player
end

target 'BasicDRMPlayback' do
    project 'BasicDRMPlayback/BasicDRMPlayback.xcodeproj'
    bitmovin_player
end

target 'BasicCasting' do
    project 'BasicCasting/BasicCasting.xcodeproj'
    bitmovin_player
    google_cast
end

target 'BasicPictureInPicture' do
    project 'BasicPictureInPicture/BasicPictureInPicture.xcodeproj'
    bitmovin_player
end

target 'AdvancedCasting' do
    project 'AdvancedCasting/AdvancedCasting.xcodeproj'
    bitmovin_player
    google_cast
end

target 'BasicMetadataHandling' do
    project 'BasicMetadataHandling/BasicMetadataHandling.xcodeproj'
    bitmovin_player
end

target 'CustomHtmlUi' do
    project 'CustomHtmlUi/CustomHtmlUi.xcodeproj'
    bitmovin_player
end

target 'ImaAdvertising' do
    project 'ImaAdvertising/ImaAdvertising.xcodeproj'
    bitmovin_player
    pod 'GoogleAds-IMA-iOS-SDK', '3.23.0'
end

target 'BasicPlaybackTV' do
    project 'BasicPlaybackTV/BasicPlaybackTV.xcodeproj'
    platform :tvos, '14.0'
    bitmovin_player
end

target 'SystemUI' do
    project 'SystemUI/SystemUI.xcodeproj'
    bitmovin_player
end

target 'BasicPlaylist' do
    project 'BasicPlaylist/BasicPlaylist.xcodeproj'
    bitmovin_player
end

target 'BasicOfflinePlayback' do
    project 'BasicOfflinePlayback/BasicOfflinePlayback.xcodeproj'
    bitmovin_player
end

target 'BackgroundPlayback' do
    project 'BackgroundPlayback/BackgroundPlayback.xcodeproj'
    bitmovin_player
end

target 'Fullscreen' do
    project 'Fullscreen/Fullscreen.xcodeproj'
    bitmovin_player
end

target 'BasicPlaylistTV' do
    project 'BasicPlaylistTV/BasicPlaylistTV.xcodeproj'
    platform :tvos, '14.0'
    bitmovin_player
end

target 'NextUpTV' do
    project 'NextUpTV/NextUpTV.xcodeproj'
    platform :tvos, '14.0'
    bitmovin_player
end

target 'SharePlay' do
    project 'SharePlay/SharePlay.xcodeproj'
    platform :ios, '15.0'
    bitmovin_player
end

target 'BasicUIKit' do
    project 'BasicUIKit/BasicUIKit.xcodeproj'
    platform :ios, '14.0'
    bitmovin_player
end

target 'BasicUIKitTV' do
    project 'BasicUIKitTV/BasicUIKitTV.xcodeproj'
    platform :tvos, '14.0'
    bitmovin_player
end

target 'AVPlayerViewController' do
    project 'AVPlayerViewController/AVPlayerViewController.xcodeproj'
    bitmovin_player
end
