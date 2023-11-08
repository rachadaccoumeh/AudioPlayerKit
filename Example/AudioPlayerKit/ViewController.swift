//
//  ViewController.swift
//  AudioPlayerKit
//
//  Created by rachadaccoumeh@gmail.com on 11/04/2023.
//  Copyright (c) 2023 rachadaccoumeh@gmail.com. All rights reserved.
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
        audioPlayer.delegate = self
        // Play this song when the SwiftBassDemo app starts:
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")
//        let path = Bundle.main.path(forResource: "sample3", ofType: "opus")
        
        // loadAudio return BASS error code 0 mean no error
        let errCode = audioPlayer.loadAudio(url: NSURL(fileURLWithPath: path!))
        
        print(audioPlayer.isPlaying())// return bool
        

        
        
        // Spectrum view
        let swiftUIView = Spectrum(audioManager: audioPlayer)
        let hostingController = UIHostingController(rootView: swiftUIView)
        // Add the SwiftUI view as a child view controller
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.75),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])

    
    }

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
            let buttonText = button.titleLabel?.text
            switch buttonText {
            case  "1.0x":
                button.setTitle( "1.5x",for: .normal)
                audioPlayer.setPlaybackSpeed(speed: 1.5)
                break;
            case  "1.5x":
                button.setTitle( "2.0x",for: .normal)
                audioPlayer.setPlaybackSpeed(speed: 2.0)
                break;
            case  "2.0x":
                button.setTitle( "0.5x",for: .normal)
                audioPlayer.setPlaybackSpeed(speed: 0.5)
                break;
            case  "0.5x":
                button.setTitle( "1.0x",for: .normal)
                audioPlayer.setPlaybackSpeed(speed: 1.0)
                break;
            default:
                break
            }
        }
    }
    func updatePosition(_ position: Double) {
        slider.setValue(Float(position), animated: true)
    }
    func playerDidFinishPlaying(_ player: AudioPlayerKit) {
        print("playerDidFinishPlaying")
    }
    func playerBeginInterruption(_ player: AudioPlayerKit) {
        print("playerBeginInterruption")
    }
    func playerEndInterruption(_ player: AudioPlayerKit, shouldResume: Bool) {
        print("playerEndInterruption")
    }
    func playerDidChangePlayingStatus(_ player: AudioPlayerKit) {
        print("playerDidChangePlayingStatus")
    }
}

