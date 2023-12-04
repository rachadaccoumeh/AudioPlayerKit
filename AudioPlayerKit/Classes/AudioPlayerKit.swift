//
//  AudioPlayerKit.swift
//  Pods
//
//  Created by Rachad Accoumeh on 04/11/2023.
//  Copyright (c) 2023 Rachad Accoumeh. All rights reserved.
//

import AVFoundation
import SwiftUI
import Combine

/// The main class for managing audio playback using the BASS library.
@objc public class AudioPlayerKit: NSObject, ObservableObject {
    /// Singleton instance for managing audio playback.
    static let audioManager = AudioPlayerKit()

    /// Delegate for receiving audio playback events.
    @objc public weak var delegate: AudioPlayerKitDelegate?
    private var notificationCenter: NotificationCenter = NotificationCenter.default
    private var audioSession = AVAudioSession.sharedInstance

    /// Represents the current volume (0.0 to 1.0).
    @objc public var volume: CGFloat = 1.0

    var timeInterval: Double = 1.0 / 60.0 // 60 frames per second
    let micOn: Bool = false
    var tempoStream: HSTREAM = 0

    /// Published array representing the spectrum of the audio.
    @Published public var spectrum: [Float] = [Float](repeating: 0.0, count: 16384 / 2)

    // MARK: Initialization

    /// Initializes the audio player and sets up audio configuration.
    public override init() {
        super.init()
        setupAudio()
    }

    deinit {
        notificationCenter.removeObserver(self)
        BASS_Free()
    }

    // MARK: Player Functions

    /**
     Returns the duration of the currently loaded audio.

     - Returns: The duration of the audio in seconds.
     */
    @objc public func duration() -> TimeInterval {
        let len = BASS_ChannelGetLength(tempoStream, DWORD(BASS_POS_BYTE))
        let time = BASS_ChannelBytes2Seconds(tempoStream, len)
        return time
    }

    /// Starts playback of the loaded audio.
    @objc public func play() {
        BASS_ChannelPlay(tempoStream, BOOL32(truncating: false))
        notifyStatusChanged()
    }

    /// Pauses the playback of the audio.
    @objc public func pause() {
        BASS_ChannelPause(tempoStream)
        notifyStatusChanged()
    }

    /// Stops the playback of the audio and resets the position to the beginning.
    @objc public func stop() {
        setPosition(position: 0)
        BASS_ChannelStop(tempoStream)
        notifyStatusChanged()
    }

    /// Checks if the audio is currently playing.
    @objc public func isPlaying() -> Bool {
        let isPlaying = BASS_ChannelIsActive(tempoStream)
        return isPlaying == BASS_ACTIVE_PLAYING
    }

    /**
     Loads audio from the specified URL.

     - Parameters:
        - url: The URL of the audio file to load.
        - play: Determines whether to start playback after loading.
        - timeInterval: The time interval for updating the audio visualization.

     - Returns: A boolean indicating whether the loading was successful.
     */
    @objc public func loadAudio(url: NSURL, play: Bool = false, timeInterval: Double = 30.0) -> Bool {
        //        do {
        //            try audioSession.setCategory(.playback)
        //            try audioSession.setActive(true)
        //        } catch {
        //            print("Error setting audio session category: \(error)")
        //        }
        self.timeInterval = 1.0 / timeInterval
        BASS_ChannelStop(tempoStream)
        BASS_StreamFree(tempoStream)

        var stream: HSTREAM

        if url.path != nil && url.path!.contains(".opus") {
            stream = BASS_OPUS_StreamCreateFile(
                BOOL32(truncating: false),
                url.path!,
                0,
                0,
                DWORD(BASS_STREAM_DECODE)
            )
        } else {
            stream = BASS_StreamCreateFile(
                BOOL32(truncating: false),
                url.path!,
                0,
                0,
                DWORD(BASS_STREAM_DECODE)
            )
        }


        tempoStream = BASS_FX_TempoCreate(stream, DWORD(BASS_FX_FREESOURCE))
        
        BASS_ChannelSetSync(
            tempoStream,
            DWORD(BASS_SYNC_END),
            0,
            channelEndedCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )

        Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true) { _ in
            BASS_ChannelGetData(self.tempoStream, &self.spectrum, BASS_DATA_FFT16384)
            self.delegate?.updatePosition?(self.position())
        }

        if play {
            self.play()
        }

        let err = BASS_ErrorGetCode()
        return err == 0
    }

    /**
     Sets the playback speed of the audio.

     - Parameter speed: The desired playback speed.
     */
    @objc public func setPlaybackSpeed(speed: Float) {
        let (tempo, _, _) = calculateTempoPitchAndSampleRateBasedOnSpeed(speed: speed)
        
        //        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO), 20) // 20% faster
        //        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO_PITCH), -3) // 3 semitones lower
        //        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO_FREQ), 44100) // 44100 Hz sample rate
        
        

        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO), tempo)
//        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO_PITCH), -3)
//        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO_FREQ), sampleRate)
    }

    /// Gets the current position of the audio playback (0.0 to 1.0).
    @objc public func position() -> Double {
        let positionBytes = BASS_ChannelGetPosition(tempoStream, DWORD(BASS_POS_BYTE))
        let len = BASS_ChannelGetLength(tempoStream, DWORD(BASS_POS_BYTE))
        return (Double)(positionBytes) / (Double)(len)
    }

    /**
     Sets the playback position of the audio.

     - Parameter position: The desired playback position (0.0 to 1.0).
     */
    @objc public func setPosition(position: CGFloat) {
        let clampedPosition = max(0.0, min(1.0, position))
        let len = BASS_ChannelGetLength(tempoStream, DWORD(BASS_POS_BYTE))
        let bytesPosition = UInt64(Double(len) * Double(clampedPosition))
        let clampedBytesPosition = min(UInt64.max, bytesPosition)
        BASS_ChannelSetPosition(tempoStream, QWORD(clampedBytesPosition), DWORD(BASS_POS_BYTE))
    }

    /**
     Sets the volume level of the audio.

     - Parameter volume: The desired volume level (0.0 to 1.0).
     */
    @objc public func setVolume(volume: CGFloat) {
        let clampedVolume = max(0.0, min(1.0, volume))
        self.volume = clampedVolume
        BASS_SetConfig(DWORD(BASS_CONFIG_GVOL_STREAM), DWORD(clampedVolume * 10000.0))
    }

    // MARK: Private Functions

    /// Sets up the audio configuration.
    private func setupAudio() {
        
        print(BASS_GetVersion())
        BASS_Init(-1, 44100, 0, nil, nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioInterruptionOccurred),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        volume = CGFloat(Double(BASS_GetConfig(DWORD(BASS_CONFIG_GVOL_STREAM))) / 10000.0)
    }

    /// Calculates tempo, pitch, and sample rate based on the specified speed.
    private func calculateTempoPitchAndSampleRateBasedOnSpeed(speed: Float) -> (tempo: Float, pitch: Float, sampleRate: Float) {
                // Calculate the tempo.
                let tempoFactor = (speed-1)*100
                print("speed \(tempoFactor)")
        
                // Calculate the pitch.
                let pitchSemitones = (log2(tempoFactor) * 12)
                print("pitchSemitones \(pitchSemitones)")
        
                // Calculate the sample rate.
                let sampleRate = (Float)(44100 * tempoFactor)
                print("sampleRate \(sampleRate)")
        
                return (tempoFactor, pitchSemitones, sampleRate)
//        let tempo = speed * 2.0
//        let pitch = speed / 2.0
//        let sampleRate = speed * 44100.0
//        return (tempo, pitch, sampleRate)
    }

    // MARK: Sync Callback and Delegate

    @objc func audioInterruptionOccurred(_ notification: Notification) {
        if let interruptionDictionary = notification.userInfo,
           let interruptionTypeRaw = interruptionDictionary[AVAudioSessionInterruptionTypeKey] as? UInt,
           let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRaw) {
            switch interruptionType {
            case .began:
                notifyBeginInterruption()
            case .ended:
                if let optionsRaw = interruptionDictionary[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsRaw)
                    notifyEndInterruption(shouldResume: options == .shouldResume)
                }
            }
        }
    }

    internal func notifyStatusChanged() {
        if let delegate = delegate {
            delegate.playerDidChangePlayingStatus?(self)
        }
    }

    internal func notifyDidFinishPlaying() {
        if let delegate = delegate {
            delegate.playerDidFinishPlaying?(self)
        }
    }

    internal func notifyBeginInterruption() {
        if let delegate = delegate {
            delegate.playerBeginInterruption?(self)
        }
    }

    internal func notifyEndInterruption(shouldResume: Bool) {
        if let delegate = delegate {
            delegate.playerEndInterruption?(self, shouldResume: shouldResume)
        }
    }
}

@_cdecl("channelEndedCallback")
func channelEndedCallback(handle: HSYNC, channel: DWORD, data: DWORD, user: UnsafeMutableRawPointer?) {
    if let user = user {
        let player = Unmanaged<AudioPlayerKit>.fromOpaque(user).takeUnretainedValue()
        DispatchQueue.main.async {
            player.notifyStatusChanged()
            player.notifyDidFinishPlaying()
        }
    }
}

// MARK: Protocol

@objc public protocol AudioPlayerKitDelegate {
    /**
     Notifies the delegate about the update in playback position.

     - Parameter position: The updated playback position.
     */
    @objc optional func updatePosition(_ position: Double)

    /**
     Notifies the delegate about changes in the playing status of the audio player.

     - Parameter player: The `AudioPlayerKit` instance.
     */
    @objc optional func playerDidChangePlayingStatus(_ player: AudioPlayerKit)

    /**
     Notifies the delegate when the audio playback has finished.

     - Parameter player: The `AudioPlayerKit` instance.
     */
    @objc optional func playerDidFinishPlaying(_ player: AudioPlayerKit)

    /**
     Notifies the delegate when an interruption occurs in the audio playback.

     - Parameter player: The `AudioPlayerKit` instance.
     */
    @objc optional func playerBeginInterruption(_ player: AudioPlayerKit)

    /**
     Notifies the delegate when an interruption in the audio playback has ended.

     - Parameters:
        - player: The `AudioPlayerKit` instance.
        - shouldResume: A boolean indicating whether playback should resume after the interruption ends.
     */
    @objc optional func playerEndInterruption(_ player: AudioPlayerKit, shouldResume: Bool)
}
