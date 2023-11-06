//
//  AudioPlayerKit.swift
//  Pods
//
//  Created by rachad accoumeh on 04/11/2023.
//  Copyright (c) 2023 rachadaccoumeh@gmail.com. All rights reserved.
//
import AVFoundation


@objc public class AudioPlayerKit: NSObject, ObservableObject {
    static let audioManager = AudioPlayerKit() // This singleton instantiates the AudioManager class and runs setupAudio()
    
    weak var delegate: AudioPlayerKitDelegate?
    private var notificationCenter: NotificationCenter = NotificationCenter.default
    private var audioSession = AVAudioSession.sharedInstance

    
    /* Represents current volume 0..1 */
    public var volume: CGFloat = 1.0
    
    
    
    let timeInterval: Double = 1.0 / 60.0 // 60 frames per second
    let micOn: Bool = false
    var tempoStream: HSTREAM = 0
    
    // Play this song when the SwiftBassDemo app starts:
    
    // Declare an array of the final values (for this frame) that we will publish to the visualization:
    @Published var spectrum: [Float] = [Float](repeating: 0.0, count: 16384 / 2) // binCount = 8,192
    
    // MARK: Init
    
    
    public override init() {
        super.init()
        setupAudio()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
        BASS_Free()
    }
    
    // MARK: player function
    
    
    /*
     Player values
     */
    public func duration()->TimeInterval{
        let len = BASS_ChannelGetLength(tempoStream, DWORD(BASS_POS_BYTE))
        let time = BASS_ChannelBytes2Seconds(tempoStream, len)
        return time
    }
    
    /*
     Player interactions
     */
    public func play(){
        BASS_ChannelPlay(tempoStream,BOOL32(truncating: false))
        self.notifyStatusChanged()
    }
    
    public func pause(){
        BASS_ChannelPause(tempoStream)
        self.notifyStatusChanged()
    }
    
    public func stop(){
        BASS_ChannelStop(tempoStream)
        self.notifyStatusChanged()
    }
    
    public func isPlaying() -> Bool{
        let isPlaying = BASS_ChannelIsActive(tempoStream)
        return isPlaying == BASS_ACTIVE_PLAYING
    }
    
    public func loadAudio(url:NSURL,play:Bool)->Bool{
//        do {
//            try audioSession.setCategory(.playback)
//            try audioSession.setActive(true)
//        } catch {
//            print("Error setting audio session category: \(error)")
//        }        
        
        //Stop channel;
        BASS_ChannelStop(tempoStream)
        //Free memory
        BASS_StreamFree(tempoStream)
        
        var stream:HSTREAM
        
        if url.path != nil && url.path!.contains(".opus") {
            // Create a sample stream from our MP3 song file:
            stream = BASS_OPUS_StreamCreateFile(BOOL32(truncating: false), // mem: false = stream the file from a filename
                                                url.path!, // file:
                                                0, // offset:
                                                0, // length: 0 = use all data up to end of file
                                                DWORD(BASS_STREAM_DECODE)) // flags:
        } else {
            stream = BASS_StreamCreateFile(BOOL32(truncating: false), // mem: false = stream the file from a filename
                                           url.path!, // file:
                                           0, // offset:
                                           0, // length: 0 = use all data up to end of file
                                           DWORD(BASS_STREAM_DECODE)) // flags:
        }
        
        // Set callback
        BASS_ChannelSetSync(tempoStream, DWORD(BASS_SYNC_END), 0, channelEndedCallback, Unmanaged.passUnretained(self).toOpaque())
//        BASS_ChannelSetSync(channel, DWORD(BASS_SYNC_END), 0, unsafeBitCast(channelEndedCallback, to: DWORD_PTR.self), Unmanaged.passUnretained(self).toOpaque())

        
        // Create a new stream with tempo, pitch, and sample rate control
        tempoStream = BASS_FX_TempoCreate(stream, DWORD(BASS_FX_FREESOURCE)) // BASS_SAMPLE_FLOAT
        
        
        // Compute the 8192-bin spectrum of the song waveform every 1/60 seconds:
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            BASS_ChannelGetData(self.tempoStream, &self.spectrum, BASS_DATA_FFT16384)
        }
        
        if(play){
            self.play()
        }
        
        let err = BASS_ErrorGetCode()
        return err == 0
        
    }
    
    public func setSpeed(speed:Float){
        let (tempo, pitch, sampleRate) = calculateTempoPitchAndSampleRateBasedOnSpeed(speed: speed)
        
        // Set the tempo, pitch, and sample rate of the new stream.
        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO),tempo)
        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO_PITCH),-3)
        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO_FREQ),sampleRate)
        
        
        
        //        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO), 20) // 20% faster
        //        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO_PITCH), -3) // 3 semitones lower
        //        BASS_ChannelSetAttribute(tempoStream, DWORD(BASS_ATTRIB_TEMPO_FREQ), 44100) // 44100 Hz sample rate
        
        
    }
    
    /* Represents current position 0..1 */
    public func position()->Double{
        let positionBytes = BASS_ChannelGetPosition(tempoStream, DWORD(BASS_POS_BYTE));
        let len = BASS_ChannelGetLength(tempoStream, DWORD(BASS_POS_BYTE));
        return (Double) (positionBytes) / (Double) (len)
    }
    
    public func setPosition(position: CGFloat) {
        let len = BASS_ChannelGetLength(tempoStream, DWORD(BASS_POS_BYTE))
        let bytesPosition = Double(len) * Double(position)
        
        BASS_ChannelSetPosition(tempoStream, QWORD(bytesPosition), DWORD(BASS_POS_BYTE))
    }
    
    public func setVolume(volume :CGFloat){
        self.volume = volume;
        BASS_SetConfig(DWORD(BASS_CONFIG_GVOL_STREAM), DWORD(volume * 10000.0));
        
    }
    
    private   func setupAudio() {
        print(BASS_GetVersion()) // This prints "33_820_928" in Xcode's console pane
        
        // Initialize the output device (i.e., speakers) that BASS should use:
        BASS_Init(-1, // device: -1 is the default device
                   44100, // freq: output sample rate is 44,100 sps
                   0, // flags:
                   nil, // win: 0 = the desktop window (use this for console applications)
                   nil) // Unused, set to nil
        // The sample format specified in the freq and flags parameters has no effect on the output on macOS or iOS.
        // The device's native sample format is automatically used.
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioInterruptionOccurred), name: .AVAudioSessionInterruption, object: nil)

        volume = CGFloat(Double(BASS_GetConfig(DWORD(BASS_CONFIG_GVOL_STREAM))) / 10000.0)
        
    }
    
    
    
    // MARK: private func
    
    
    private func calculateTempoPitchAndSampleRateBasedOnSpeed(speed: Float) -> (tempo: Float, pitch: Float, sampleRate: Float) {
        // Calculate the tempo.
        let tempoFactor = (speed-1)*100
        print("speed \(tempoFactor)")
        
        // Calculate the pitch.
        let pitchSemitones = (log2(speed) * 12)
        print("pitchSemitones \(pitchSemitones)")
        
        // Calculate the sample rate.
        let sampleRate = (Float)(44100 * speed)
        print("sampleRate \(sampleRate)")
        
        return (tempoFactor, pitchSemitones, sampleRate)
    }
    
    // MARK: sync callback and delegate
    
    @objc func audioInterruptionOccurred(_ notification: Notification) {
        if let interruptionDictionary = notification.userInfo,
           let interruptionTypeRaw = interruptionDictionary[AVAudioSessionInterruptionTypeKey] as? UInt,
           let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeRaw) {
            switch interruptionType {
            case .began:
                notifyBeginInterruption()
            case .ended:
                if let optionsRaw = interruptionDictionary[AVAudioSessionInterruptionOptionKey] as? UInt{
                   let options = AVAudioSessionInterruptionOptions(rawValue: optionsRaw)
                    notifyEndInterruption(shouldResume: options == .shouldResume)
                }
            }
        }
    }
    
    internal func notifyStatusChanged() {
        if let delegate = delegate{
            delegate.playerDidChangePlayingStatus?(self)
        }
    }

    internal func notifyDidFinishPlaying(){
        if let delegate = delegate{
            delegate.playerDidFinishPlaying?(self)
        }
    }
    
    internal func notifyBeginInterruption() {
        if let delegate = delegate{
            delegate.playerBeginInterruption?(self)
        }
    }
    
    internal func notifyEndInterruption(shouldResume: Bool) {
        if let delegate = delegate{
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


// MARK: protocol


@objc protocol AudioPlayerKitDelegate {
    /**
     *  Notifies the delegate about playing status changed
     *
     *  @param player AudioPlayerKit
     */
    @objc optional func playerDidChangePlayingStatus(_ player: AudioPlayerKit)
    /**
     *  Will be called when track is over
     *
     *  @param player AudioPlayerKit
     */
    @objc optional func playerDidFinishPlaying(_ player: AudioPlayerKit)
    /**
     *   Will be called when interruption occured. For ex. phone call. Basically you should call - (void)pause in this case.
     *
     *  @param player AudioPlayerKit
     */
    @objc optional func playerBeginInterruption(_ player: AudioPlayerKit)
    /**
     *   Will be called when interruption ended. For ex. phone call ended. It's up to you to decide to call - (void)resume or not.
     *
     *  @param player AudioPlayerKit
     *  @param should BOOL
     */
    @objc optional func playerEndInterruption(_ player: AudioPlayerKit, shouldResume: Bool)
}

