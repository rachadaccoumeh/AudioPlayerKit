//
//  ViewController.swift
//  AudioPlayerKit
//
//  Created by rachadaccoumeh@gmail.com on 11/04/2023.
//  Copyright (c) 2023 rachadaccoumeh@gmail.com. All rights reserved.
//

import UIKit
import AudioPlayerKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Play this song when the SwiftBassDemo app starts:
        let audioPlayer = AudioPlayerKit()
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")
//        let path = Bundle.main.path(forResource: "sample3", ofType: "opus")
        audioPlayer.loadAudio(url: NSURL(fileURLWithPath: path!), play: false)
        audioPlayer.play()
        audioPlayer.setSpeed(speed: 0.5)
        
        audioPlayer.pause()
        audioPlayer.play()
        print(audioPlayer.isPlaying())
    
    }



}

