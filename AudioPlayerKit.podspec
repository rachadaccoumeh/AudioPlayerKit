#
# Be sure to run `pod lib lint AudioPlayerKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AudioPlayerKit'
  s.version          = '0.1.0'
  s.summary          = 'Audio player support most audio type with many feature '

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/rachadaccoumeh@gmail.com/AudioPlayerKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rachadaccoumeh@gmail.com' => 'rachadaccoumeh@gmail.com' }
  s.source           = { :git => 'https://github.com/rachadaccoumeh@gmail.com/AudioPlayerKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'AudioPlayerKit/Classes/**/*'
#  s.vendored_frameworks = 'AudioPlayerKit/Classes/BASS/bass.xcframework'
#  s.frameworks = 'AudioPlayerKit/Classes/BASS/bass.xcframework'
#  s.preserve_paths = 'AudioPlayerKit/Classes/BASS/bass.h'
#  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/AudioPlayerKit/Classes/BASS/bass.h' }

#  s.vendored_frameworks = 'MyFramework.framework'
#  /Users/rachadaccoumeh/Desktop/AudioPlayerKit/AudioPlayerKit/Classes/BASS/bass.xcframework
  # s.resource_bundles = {
  #   'AudioPlayerKit' => ['AudioPlayerKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
