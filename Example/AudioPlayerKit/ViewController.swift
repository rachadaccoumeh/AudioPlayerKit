//
//  ViewController.swift
//  AudioPlayerKit
//
//  Created by Rachad Accoumeh on 11/04/2023.
//  Copyright (c) 2023 Rachad Accoumeh. All rights reserved.
//

import UIKit
import AudioPlayerKit
import SwiftUI
import Combine

class ViewController: UIViewController, AudioPlayerKitDelegate {
    @IBOutlet weak var slider: UISlider!
    var audioPlayer = AudioPlayerKit()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate for receiving audio player events
        audioPlayer.delegate = self

        // Example: Load an MP3 file named "music.mp3" from the app bundle
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")
        let errCode = audioPlayer.loadAudio(url: NSURL(fileURLWithPath: path!))
        
        // Example: Check if the audio is currently playing
        print(audioPlayer.isPlaying())

        // Example: Create and display a SwiftUI Spectrum view
        let swiftUIView = Spectrum(audioManager: audioPlayer)
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.75),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
    }

    // MARK: - IBActions

    @IBAction func playAction(_ sender: Any) {
        audioPlayer.play()
    }

    @IBAction func pauseAction(_ sender: Any) {
        audioPlayer.pause()
    }

    @IBAction func stopAction(_ sender: Any) {
        audioPlayer.stop()
    }

    @IBAction func sliderHandler(_ sender: Any) {
        if let slider = sender as? UISlider {
            audioPlayer.setPosition(position: CGFloat(slider.value))
        }
    }

    @IBAction func audioSpeed(_ sender: Any) {
        if let button = sender as? UIButton {
            handleAudioSpeedButton(button)
        }
    }

    // MARK: - AudioPlayerKitDelegate Methods

    func updatePosition(_ position: Double) {
        slider.setValue(Float(position), animated: true)
    }

    func playerDidFinishPlaying(_ player: AudioPlayerKit) {
        print("Audio playback finished.")
    }

    func playerBeginInterruption(_ player: AudioPlayerKit) {
        print("Audio player interruption began.")
    }

    func playerEndInterruption(_ player: AudioPlayerKit, shouldResume: Bool) {
        print("Audio player interruption ended. Should resume: \(shouldResume)")
    }

    func playerDidChangePlayingStatus(_ player: AudioPlayerKit) {
        print("Audio player playing status changed.")
    }

    // MARK: - Private Methods

    private func handleAudioSpeedButton(_ button: UIButton) {
        if let buttonText = button.titleLabel?.text {
            switch buttonText {
            case "1.0x":
                setAudioSpeedButtonTitle(button, speed: 1.5)
            case "1.5x":
                setAudioSpeedButtonTitle(button, speed: 2.0)
            case "2.0x":
                setAudioSpeedButtonTitle(button, speed: 0.5)
            case "0.5x":
                setAudioSpeedButtonTitle(button, speed: 1.0)
            default:
                break
            }
        }
    }

    private func setAudioSpeedButtonTitle(_ button: UIButton, speed: Float) {
        button.setTitle("\(speed)x", for: .normal)
        audioPlayer.setPlaybackSpeed(speed: speed)
    }
}
