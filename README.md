# AudioPlayerKit - Your Ultimate Audio Player Library

[![CI Status](https://img.shields.io/travis/rachadaccoumeh@gmail.com/AudioPlayerKit.svg?style=flat)](https://travis-ci.org/rachadaccoumeh@gmail.com/AudioPlayerKit)
[![Version](https://img.shields.io/cocoapods/v/AudioPlayerKit.svg?style=flat)](https://cocoapods.org/pods/AudioPlayerKit)
[![License](https://img.shields.io/cocoapods/l/AudioPlayerKit.svg?style=flat)](https://cocoapods.org/pods/AudioPlayerKit)
[![Platform](https://img.shields.io/cocoapods/p/AudioPlayerKit.svg?style=flat)](https://cocoapods.org/pods/AudioPlayerKit)


AudioPlayerKit is your go-to solution for all your audio playback needs in iOS applications. This versatile and user-friendly library seamlessly integrates into both Objective-C and Swift projects. It's the modern alternative to the outdated APAudioPlayer, offering a wide array of enhanced features.

## Key Features:

1. Playback Control: AudioPlayerKit simplifies audio playback with easy-to-use controls like Play, Pause, and Stop. You can effortlessly manage audio files in various formats, including *.m4a, *.mp3, *.mp2, *.mp1, *.wave, *.ogg, *.wav, *.aiff, *.opus, *.flac, *.wv, and more. The library is designed to be extendable, supporting additional audio formats.
2. Real-time Spectrum Analysis: Gain insights into your audio content with real-time spectrum analysis. AudioPlayerKit provides you with a spectrum data array for a more immersive audio experience.
3. Adjustable Playback Speed: Customize the audio playback speed to your liking. Speed up or slow down audio content to fit various use cases, such as language learning or audio transcription.
4. Delegate Support: AudioPlayerKit uses a robust delegate system, allowing you to receive updates on various player events, such as changes in player status, playback completion, interruptions, and more. The available delegate methods include:
    - playerDidChangePlayingStatus: Get notified when the player's playing status changes.
    - playerDidFinishPlaying: Receive an event when audio playback is complete.
    - playerEndInterruption: Handle interruptions gracefully and resume playback.
    - playerDidFinishPlaying: Stay informed when the player finishes playing.
5. Built on BASS from un4seen: AudioPlayerKit leverages the powerful BASS library from un4seen, known for its high-performance audio capabilities. This solid foundation ensures reliable and efficient audio playback.
6. Easy Integration: AudioPlayerKit seamlessly integrates into your Swift or Objective-C iOS projects, offering a simple and intuitive interface for audio control and analysis.




## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
import AudioPlayerKit

// Initialize the audio player
let player = AudioPlayerKit()

// Load an audio file (replace "your_audio_file" with the actual filename)
if let audioURL = Bundle.main.url(forResource: "your_audio_file", withExtension: "mp3") {
    player.loadAudio(from: audioURL) // you can use autoplay param default to false and the update interval default is 30/s
}

// Control playback
player.play()
player.pause()
player.stop()

// Adjust playback speed
player.setPlaybackSpeed(1.5) // Speed up audio playback by 1.5 times

// Register delegates to receive updates
player.delegate = self

// Implement delegate methods to handle audio events
extension YourViewController: AudioPlayerKitDelegate {
    // Handle player status changes
    func playerDidChangePlayingStatus() {
        // Implement your code here
    }
    
    // Handle playback completion
    func playerDidFinishPlaying() {
        // Implement your code here
    }
    
    // Handle interruptions and resume playback
    func playerEndInterruption() {
        // Implement your code here
    }
    
    // Handle when the player finishes playing
    func playerDidFinishPlaying() {
        // Implement your code here
    }
}
```

## Requirements

- ios 13+

## Installation

AudioPlayerKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AudioPlayerKit'
```

## GitHub Repository

AudioPlayerKit is an open-source project available on GitHub. You can find the repository [here](https://github.com/rachadaccoumeh/AudioPlayerKit). We welcome contributions and assistance from the community to make AudioPlayerKit even better!

AudioPlayerKit brings a wealth of powerful features to your iOS audio applications, ensuring a top-notch user experience and a multitude of options for audio manipulation and analysis. This library is your go-to choice for all your audio-related tasks, making it easy to integrate and utilize audio playback capabilities in your projects.

## what is next

- support macos
- add waveform
- audio streaming


## Author

Rachad Accoumeh, <rachadaccoumeh@gmail.com>

## License

AudioPlayerKit is available under the MIT license. See the LICENSE file for more info.

## BASS

The BASS library from Un4seen Developments is a powerful and versatile audio library tailored for software developers. Renowned for its broad support of audio formats, BASS facilitates seamless integration of advanced audio features into applications. With capabilities including playback, streaming, and recording, the library is a favored choice for developers aiming to implement high-quality and low-latency audio functionality. BASS finds application in diverse contexts such as music players, gaming software, and multimedia applications, where precise audio control is paramount.

[BASS](http://www.un4seen.com)

[BASS-lisence](http://www.un4seen.com/bass.html#license)
