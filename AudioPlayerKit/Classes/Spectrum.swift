// Spectrum.swift
// SwiftBassDemo
//
// This view renders a visualization of the simple one-dimensional spectrum (using a mean-square amplitude scale) of the music.
// It renders only the first 512 of the 8192 bins. Thus, the highest frequency is 44,100 / 32 = 1,378.125 Hz
//
// The horizontal axis is linear frequency (from 0.0 Hz on the left to 1,378.125 Hz on the right).
// The vertical axis shows (in red) the mean-square amplitude of the instantaneous spectrum of the audio being played.
// The red peaks are spectral lines depicting the harmonics of the musical notes being played.
//

import SwiftUI

public struct Spectrum: View {

    @ObservedObject var audioManager: AudioPlayerKit // Observe the instance of AudioManager passed from ContentView
    var foregroundColor: Color

    // Constants for better readability and flexibility
    private let binCount: Int = 512
    private let maxHeightMultiplier: CGFloat = 4.0

    public init(audioManager: AudioPlayerKit, foregroundColor: Color = Color.red) {
        self.audioManager = audioManager
        self.foregroundColor = foregroundColor
    }

    public var body: some View {
        GeometryReader { geometry in
            let width: CGFloat = geometry.size.width
            let height: CGFloat = geometry.size.height

            var x: CGFloat = 0.0
            var y: CGFloat = 0.0
            var upRamp: CGFloat = 0.0
            var magY: CGFloat = 0.0

            Path { path in
                path.move(to: CGPoint(x: CGFloat(0.0), y: height)) // Bottom-left corner of the pane

                for bin in 0 ..< binCount {
                    // upRamp goes from 0.0 to 1.0 as bin goes from 0 to binCount
                    upRamp = CGFloat(bin) / CGFloat(binCount)
                    x = upRamp * width
                    magY = CGFloat(audioManager.spectrum[bin]) * height * maxHeightMultiplier
                    magY = min(max(0.0, magY), height)
                    y = height - magY
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(lineWidth: 2.0)
            .foregroundColor(foregroundColor) // Foreground color = red
        }
    }
}
