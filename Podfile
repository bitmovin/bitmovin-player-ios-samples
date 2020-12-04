platform :ios, '10.0'

source 'https://cdn.cocoapods.org'
source 'https://github.com/bitmovin/cocoapod-specs.git'

workspace 'BitmovinPlayerSamples'

def bitmovin_player
  pod 'BitmovinPlayer', '2.57.1'
end

def google_cast
  pod 'google-cast-sdk', '4.4.8'
end

target 'BasicPlayback' do
    project 'BasicPlayback/BasicPlayback.xcodeproj'
    use_frameworks!
    bitmovin_player
end

target 'BasicPlaybackObjectiveC' do
    project 'BasicPlaybackObjectiveC/BasicPlaybackObjectiveC.xcodeproj'
    use_frameworks!
    bitmovin_player
end

target 'BasicDRMPlayback' do
    project 'BasicDRMPlayback/BasicDRMPlayback.xcodeproj'
    use_frameworks!
    bitmovin_player
end

target 'BasicCasting' do
    project 'BasicCasting/BasicCasting.xcodeproj'
    use_frameworks!
    bitmovin_player
    google_cast
end

target 'AdvancedCasting' do
    project 'AdvancedCasting/AdvancedCasting.xcodeproj'
    use_frameworks!
    bitmovin_player
    google_cast
end

target 'BasicMetadataHandling' do
    project 'BasicMetadataHandling/BasicMetadataHandling.xcodeproj'
    use_frameworks!
    bitmovin_player
end

target 'CustomHtmlUi' do
    project 'CustomHtmlUi/CustomHtmlUi.xcodeproj'
    use_frameworks!
    bitmovin_player
end

target 'BasicAds' do
    project 'BasicAds/BasicAds.xcodeproj'
    use_frameworks!
    bitmovin_player
    pod 'GoogleAds-IMA-iOS-SDK', '3.12.1'
end

target 'BasicPlaybackTV' do
    project 'BasicPlaybackTV/BasicPlaybackTV.xcodeproj'
    use_frameworks!
    platform :tvos, '10.0'
    bitmovin_player
end

target 'SystemUI' do
    project 'SystemUI/SystemUI'
    use_frameworks!
    bitmovin_player
end

target 'BasicPlaylist' do
    project 'BasicPlaylist/BasicPlaylist'
    use_frameworks!
    bitmovin_player
end

target 'BasicOfflinePlayback' do
    project 'BasicOfflinePlayback/BasicOfflinePlayback.xcodeproj'
    use_frameworks!
    bitmovin_player
end

target 'BackgroundPlayback' do
    project 'BackgroundPlayback/BackgroundPlayback.xcodeproj'
    use_frameworks!
    bitmovin_player
end

target 'BasicFullscreenHandling' do
    project 'BasicFullscreenHandling/BasicFullscreenHandling.xcodeproj'
    use_frameworks!
    bitmovin_player
    pod 'SwiftLint'
end
