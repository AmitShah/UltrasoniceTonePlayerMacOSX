//
//  AVTonePlayerUnit.swift
//  test-quiet-macosx
//
//  Created by Amit Shah on 2019-05-29.
//  Copyright © 2019 Amit Shah. All rights reserved.
//

import Foundation
import AVFoundation

class AVTonePlayerUnit: AVAudioPlayerNode {
    let bufferCapacity: AVAudioFrameCount = 1024
    let sampleRate: Double = 44_100.0
    
    var frequency: Double = 440.0
    var amplitude: Double = 0.25
    
    private var theta: Double = 0.0
    private var audioFormat: AVAudioFormat!
    
    override init() {
        super.init()
        audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
    }
    
    func prepareBuffer() -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: bufferCapacity)
        fillBuffer(buffer)
        return buffer
    }
    
    func fillBuffer(_ buffer: AVAudioPCMBuffer) {
        let data = buffer.floatChannelData?[0]
        let numberFrames = buffer.frameCapacity
        var theta = self.theta
        let theta_increment = 2.0 * .pi * self.frequency / self.sampleRate
        
        for frame in 0..<Int(numberFrames) {
            data?[frame] = Float32(sin(theta) * amplitude)
            
            theta += theta_increment
            if theta > 2.0 * .pi {
                theta -= 2.0 * .pi
            }
        }
        buffer.frameLength = numberFrames
        self.theta = theta
    }
    
    func scheduleBuffer() {
        let buffer = prepareBuffer()
        self.scheduleBuffer(buffer)
        {
            if self.isPlaying {
                NSLog("Done playing");
                //self.scheduleBuffer()
            }
        }
    }
    
    func preparePlaying() {
        scheduleBuffer()
        //scheduleBuffer()
        //scheduleBuffer()
        //scheduleBuffer()
    }
    
    func scheduleBuffer(_ buffer:AVAudioPCMBuffer){
        //let buffer = self.toPCMBuffer(data:data)
        super.scheduleBuffer(buffer)
            {
                if self.isPlaying {
                    NSLog("Done playing buffer");
                    //self.scheduleBuffer()
                }
            }


    }
    
//    func toNSData(PCMBuffer: AVAudioPCMBuffer) -> NSData {
//        let channelCount = 1  // given PCMBuffer channel count is 1
//        var channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
//        var ch0Data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameCapacity * PCMBuffer.format.streamDescription.memory.mBytesPerFrame))
//        return ch0Data
//    }
    
    func toPCMBuffer(data: NSData) -> AVAudioPCMBuffer {
        var PCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(data.length))
        PCMBuffer.frameLength = PCMBuffer.frameCapacity
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: Int(PCMBuffer.format.channelCount))
        data.getBytes(UnsafeMutablePointer<Void>(channels[0]) , length: data.length)
        return PCMBuffer
    }
}
