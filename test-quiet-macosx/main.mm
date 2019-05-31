//
//  main.m
//  test-quiet-macosx
//
//  Created by Amit Shah on 2019-05-24.
//  Copyright © 2019 Amit Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/NSSound.h>
#import <quiet.h>
#import <sndfile.h>
#import "Cocoa/Cocoa.h"
#import "test_quiet_macosx-Swift.h"
#include <math.h>
#include <stdio.h>

#pragma once
#if UNITY_METRO
#define EXPORT_API __declspec(dllexport) __stdcall
#elif UNITY_WIN
#define EXPORT_API __declspec(dllexport)
#else
#define EXPORT_API
#endif

static AVAudioEngine* engine;
static AVAudioFormat * format;
static AVTonePlayerUnit * tone;

AVAudioPCMBuffer * create_buffer(quiet_sample_t* samples, int sample_length ){
    AVAudioPCMBuffer * buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:sample_length];
    
    Float32* channelData = buffer.floatChannelData[0];
    for(int i=0; i < sample_length; i++){
        channelData[i]= Float32(samples[i]);
    
    }
    //channelData= &(Float32 *)samples;
    AVAudioFrameCount numberFrames = buffer.frameCapacity;
    buffer.frameLength = numberFrames;
    
    return buffer;
    
}

SNDFILE *wav_open(const char *fname, float sample_rate) {
    SF_INFO sfinfo;
    
    memset(&sfinfo, 0, sizeof(sfinfo));
    sfinfo.samplerate = sample_rate;
    sfinfo.channels = 1;
    sfinfo.format = (SF_FORMAT_WAV | SF_FORMAT_FLOAT);
    
    return sf_open(fname, SFM_WRITE, &sfinfo);
}

size_t wav_write(SNDFILE *wav, const quiet_sample_t *samples, size_t sample_len) {
    return sf_write_float(wav, samples, sample_len);
}

//void output_audio(NSData * data){
//    AVTonePlayerUnit * tone = [[AVTonePlayerUnit alloc] init];
//
//    engine = [[AVAudioEngine alloc] init];
//    AVAudioFormat* format = [[AVAudioFormat alloc]  initStandardFormatWithSampleRate:tone.sampleRate channels:1];
//
//
//    [engine attachNode:tone];
//    //let mixer = engine.mainMixerNode
//    //[engine connect(tone, to: mixer, format: format)
//    [engine connect:tone to:engine.mainMixerNode format:format];
//    NSError*error;
//    [engine startAndReturnError:&error];
//    [tone preparePlaying];
//    [tone play];
//
//    engine.mainMixerNode.volume = 1.0;
//
//
//}

uint8_t* in_mem_wav(){
    long totalAudioLen = 0;
    long totalDataLen = 0;
    long longSampleRate = 44100;
    int channels = 1;
    long byteRate = 16 * 44100 * channels/8;
    
    Byte *header = (Byte*)malloc(44);
    header[0] = 'R';  // RIFF/WAVE header
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    header[4] = (Byte) (totalDataLen & 0xff);
    header[5] = (Byte) ((totalDataLen >> 8) & 0xff);
    header[6] = (Byte) ((totalDataLen >> 16) & 0xff);
    header[7] = (Byte) ((totalDataLen >> 24) & 0xff);
    header[8] = 'W';
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f';  // 'fmt ' chunk
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    header[16] = 16;  // 4 bytes: size of 'fmt ' chunk
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1;  // format = 1
    header[21] = 0;
    header[22] = (Byte) channels;
    header[23] = 0;
    header[24] = (Byte) (longSampleRate & 0xff);
    header[25] = (Byte) ((longSampleRate >> 8) & 0xff);
    header[26] = (Byte) ((longSampleRate >> 16) & 0xff);
    header[27] = (Byte) ((longSampleRate >> 24) & 0xff);
    header[28] = (Byte) (byteRate & 0xff);
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
    header[32] = (Byte) (2 * 8 / 8);  // block align
    header[33] = 0;
    header[34] = 16;  // bits per sample
    header[35] = 0;
    header[36] = 'd';
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    header[40] = (Byte) (totalAudioLen & 0xff);
    header[41] = (Byte) ((totalAudioLen >> 8) & 0xff);
    header[42] = (Byte) ((totalAudioLen >> 16) & 0xff);
    header[43] = (Byte) ((totalAudioLen >> 24) & 0xff);
    
    return header;
}

void wav_close(SNDFILE *wav) { sf_close(wav); }

float freq2rad(float freq) { return freq * 2 * M_PI; }

const int sample_rate = 44100;

float normalize_freq(float freq, float sample_rate) {
    return freq2rad(freq / (float)(sample_rate));
}

static int encode_to_wav(const char *out_fname,
                  const quiet_encoder_options *opt) {
   
    
    SNDFILE *wav = wav_open(out_fname, sample_rate);
    format =  [[AVAudioFormat alloc] initStandardFormatWithSampleRate: sample_rate channels: 1];
    engine = [[AVAudioEngine alloc] init];
    tone = [[AVTonePlayerUnit alloc] init];
    [engine attachNode:tone];
    
    //let mixer = engine.mainMixerNode
    //[engine connect(tone, to: mixer, format: format)
    [engine connect:tone to:engine.mainMixerNode format:format];
    NSError*error;
    [engine startAndReturnError:&error];
    
    size_t payload_len = 4;
    //uint8_t *payload = malloc(1*sizeof(uint8_t));
    uint8_t payload[] = {104,101,108,108};
//    for (size_t j = 0; j < payload_len; j++) {
//        payload[j] = rand() & 0xff;
//    }

    if (wav == NULL) {
        printf("failed to open wav file for writing\n");
        return 1;
    }
    
    quiet_encoder *e = quiet_encoder_create(opt, sample_rate);
    
    size_t block_len = 16384;
    uint8_t *readbuf = (uint8_t*)malloc(block_len * sizeof(uint8_t));
    size_t samplebuf_len = 128;
    quiet_sample_t *samplebuf = (quiet_sample_t*)malloc(samplebuf_len * sizeof(quiet_sample_t));
    bool done = false;
    if (readbuf == NULL) {
        return 1;
    }
    if (samplebuf == NULL) {
        return 1;
    }
    int count = 0;
    size_t frame_len = quiet_encoder_get_frame_len(e);
        ssize_t written = quiet_encoder_send(e, payload, frame_len);
        written = samplebuf_len;
        while (written == samplebuf_len) {
            
            written = quiet_encoder_emit(e, samplebuf, samplebuf_len);
            if (written > 0) {
                //NSLog(@"%.9f",*samplebuf);
                //NSLog(@"Counter:%d",count++);
                wav_write(wav, samplebuf, written);
                AVAudioPCMBuffer* buffer =  create_buffer(samplebuf, written);
                
                //AVAudioPCMBuffer * buffer = create_buffer(samplebuf, samplebuf_len);
                //[tone fillBuffer:buffer];

                [tone scheduleBuffer:buffer];
                //[md appendBytes:<#(nonnull const void *)#> length:<#(NSUInteger)#>
                

                
            }
        }
    
    
    
   
    
    //[tone scheduleBuffer:[NSData dataWithBytes:(const void *)samplebuf length:samplebuf_len]];
    //[tone prepareBuffer];
    //[tone preparePlaying];
    [tone play];
    
    engine.mainMixerNode.volume = 1.0;

//    quiet_encoder_destroy(e);
//    free(readbuf);
//    free(samplebuf);
//    wav_close(wav);
    
    return 0;
}




extern "C" int EXPORT_API main2() {
    
    const char *fname = "/Users/amitshah/Downloads/quiet-requirements/quiet-master/quiet-profiles.json";
    const char *profilename = "ultrasonic-experimental";



    quiet_encoder_options *encodeopt =
    quiet_encoder_profile_filename(fname, profilename);

    if (!encodeopt) {
        exit(1);
    }

    encode_to_wav("/Users/amitshah/Downloads/quiet-requirements/encoded.wav", encodeopt);


    free(encodeopt);
//    NSBackgroundActivityScheduler *activity = [[NSBackgroundActivityScheduler alloc] initWithIdentifier:@"com.example.MyApp.updatecheck"];
//
//         NSError *error;
//         NSURL *wavfile=
//         [NSURL fileURLWithPath:@"/Users/amitshah/Downloads/quiet-requirements/encoded.wav"];
//
//         AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:wavfile error:&error];
//         NSLog(@"%f", audioPlayer.duration);
//         [audioPlayer prepareToPlay];
//
//
//
//
//         [audioPlayer play];




    return 0;
}



int main(int argc, const char * argv[])
{
    // Autorelease Pool:
    // Objects declared in this scope will be automatically
    // released at the end of it, when the pool is "drained".

    // Create a shared app instance.
    // This will initialize the global variable
    // 'NSApp' with the application instance.
    [NSApplication sharedApplication];

    //
    // Create a window:
    //

    // Style flags:
    NSUInteger windowStyle = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask;

    // Window bounds (x, y, width, height).
    NSRect windowRect = NSMakeRect(100, 100, 400, 400);
    NSWindow * window = [[NSWindow alloc] initWithContentRect:windowRect
                                                    styleMask:windowStyle
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];

    // Window controller:
    NSWindowController * windowController = [[NSWindowController alloc] initWithWindow:window];

    // This will add a simple text view to the window,
    // so we can write a test string on it.
    NSTextView * textView = [[NSTextView alloc] initWithFrame:windowRect];

    [window setContentView:textView];
    [textView insertText:@"Hello OSX/Cocoa world!"];

    // TODO: Create app delegate to handle system events.
    // TODO: Create menus (especially Quit!)
    [window orderFrontRegardless];
    // Show window and run event loop.
    
    
    main2();
    //output_audio(Nil);
    [NSApp run];
        
    
    return 0;
}

void playAudio(){
    AudioObjectPropertyAddress addr;
    UInt32 size;
    AudioDeviceID deviceID = 0;
    addr.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    addr.mScope = kAudioObjectPropertyScopeGlobal;
    addr.mElement = 0;
    size = sizeof(AudioDeviceID);
    int err = AudioObjectGetPropertyData(kAudioObjectSystemObject, &addr, 0, NULL, &size, &deviceID);
    
    //get its sample rate
    addr.mSelector = kAudioDevicePropertyNominalSampleRate;
    addr.mScope = kAudioObjectPropertyScopeGlobal;
    addr.mElement = 0;
    size = sizeof(Float64);
    Float64 outSampleRate;
    int err2 = AudioObjectGetPropertyData(deviceID, &addr, 0, NULL, &size, &outSampleRate);
    //if there is no error, outSampleRate contains the sample rate

}

