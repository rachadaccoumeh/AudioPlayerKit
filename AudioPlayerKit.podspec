#
# Be sure to run `pod lib lint AudioPlayerKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AudioPlayerKit'
  s.version          = '0.2.3'
  s.summary          = 'Audio player support most audio type with many feature. '
  s.description      = <<-DESC
  AudioPlayerKit - Your Ultimate Audio Player Library

  AudioPlayerKit is your go-to solution for all your audio playback needs in iOS applications. This versatile and user-friendly library seamlessly integrates into both Objective-C and Swift projects. It's the modern alternative to the outdated APAudioPlayer, offering a wide array of enhanced features.

  Key Features:

  Playback Control: AudioPlayerKit simplifies audio playback with easy-to-use controls like Play, Pause, and Stop. You can effortlessly manage audio files in various formats, including *.m4a, *.mp3, *.mp2, *.mp1, *.wave, *.ogg, *.wav, *.aiff, *.opus, *.flac, *.wv, and more. The library is designed to be extendable, supporting additional audio formats.

  Real-time Spectrum Analysis: Gain insights into your audio content with real-time spectrum analysis. AudioPlayerKit provides you with a spectrum data array for a more immersive audio experience.

  Adjustable Playback Speed: Customize the audio playback speed to your liking. Speed up or slow down audio content to fit various use cases, such as language learning or audio transcription.

  Delegate Support: AudioPlayerKit uses a robust delegate system, allowing you to receive updates on various player events, such as changes in player status, playback completion, interruptions, and more. The available delegate methods include:

  playerDidChangePlayingStatus: Get notified when the player's playing status changes.
  playerDidFinishPlaying: Receive an event when audio playback is complete.
  playerEndInterruption: Handle interruptions gracefully and resume playback.
  playerDidFinishPlaying: Stay informed when the player finishes playing.
  Built on BASS from un4seen: AudioPlayerKit leverages the powerful BASS library from un4seen, known for its high-performance audio capabilities. This solid foundation ensures reliable and efficient audio playback.

  Easy Integration: AudioPlayerKit seamlessly integrates into your Swift or Objective-C iOS projects, offering a simple and intuitive interface for audio control and analysis.

  GitHub Repository:
  AudioPlayerKit is an open-source project available on GitHub. You can find the repository here. We welcome contributions and assistance from the community to make AudioPlayerKit even better!

  AudioPlayerKit brings a wealth of powerful features to your iOS audio applications, ensuring a top-notch user experience and a multitude of options for audio manipulation and analysis. This library is your go-to choice for all your audio-related tasks, making it easy to integrate and utilize audio playback capabilities in your projects.
  DESC

  s.homepage         = 'https://github.com/rachadaccoumeh/AudioPlayerKit'
  s.screenshots     = 'https://raw.githubusercontent.com/rachadaccoumeh/AudioPlayerKit/master/Screenshots/screenshot1.png' , 'https://raw.githubusercontent.com/rachadaccoumeh/AudioPlayerKit/master/Screenshots/screenshot2.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rachad Accoumeh' => 'rachadaccoumeh@gmail.com' }
  s.source           = { :git => 'https://github.com/rachadaccoumeh/AudioPlayerKit.git', :tag => s.version.to_s }
   s.social_media_url = 'https://linkedin.com/in/rachad-accoumeh'#'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.platform          = :ios, '13.0'
  s.swift_versions    = '5.0'
  
  s.resource = 'AudioPlayerKit/Classes/BASS/**/*.txt', 'AudioPlayerKit/Classes/BASS/**/*.chm'
  s.ios.vendored_frameworks = 'AudioPlayerKit/Classes/BASS/bass.xcframework','AudioPlayerKit/Classes/BASS/bass_fx.xcframework', 'AudioPlayerKit/Classes/BASS/bassopus.xcframework', 'AudioPlayerKit/Classes/BASS/bassflac.xcframework'
  s.requires_arc = true
  s.frameworks   = 'AVFoundation', 'bass', 'bass_fx', 'bassopus', 'bassflac'
  s.source_files = 'AudioPlayerKit/Classes/**/*.{h,m,swift}'
  s.preserve_paths = 'AudioPlayerKit/Classes/**/*.h'
  s.public_header_files = 'AudioPlayerKit/Classes/**/*.h'
#  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/AudioPlayerKit/Classes/BASS/*.h' }


#  s.vendored_frameworks = 'AudioPlayerKit.framework'
  # s.resource_bundles = {
  #   'AudioPlayerKit' => ['AudioPlayerKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

end
