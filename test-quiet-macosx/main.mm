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
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"


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
static  quiet_encoder_options *encodeopt;
static  quiet_encoder *e ;

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





void wav_close(SNDFILE *wav) { sf_close(wav); }

float freq2rad(float freq) { return freq * 2 * M_PI; }

const int sample_rate = 44100;

float normalize_freq(float freq, float sample_rate) {
    return freq2rad(freq / (float)(sample_rate));
}

static int encode_to_audio(uint8_t* payload, size_t payload_len) {
    
    size_t block_len = 16384;
    uint8_t *readbuf = (uint8_t*)malloc(block_len * sizeof(uint8_t));
    size_t samplebuf_len = 64;
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
                
                AVAudioPCMBuffer* buffer =  create_buffer(samplebuf, written);
                [tone scheduleBuffer:buffer];
                
                
                
            }
        }
    
    
    
   
    
    [tone play];
    
    //engine.mainMixerNode.volume = 1.0;

    free(readbuf);
    free(samplebuf);
//    wav_close(wav);
    
    return 0;
}




extern "C" int EXPORT_API main2() {
    
   
    //encode_to_wav("/Users/amitshah/Downloads/quiet-requirements/encoded.wav", encodeopt);


   
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

void initialize_audio_engine(){
    const char *fname = "/Users/amitshah/Downloads/quiet-requirements/quiet-master/quiet-profiles.json";
    const char *profilename = "ultrasonic-experimental";
    
    encodeopt =
    quiet_encoder_profile_filename(fname, profilename);
    
    if (!encodeopt) {
        exit(1);
    }
    e = quiet_encoder_create(encodeopt, sample_rate);
    format =  [[AVAudioFormat alloc] initStandardFormatWithSampleRate: sample_rate channels: 1];
    engine = [[AVAudioEngine alloc] init];
    tone = [[AVTonePlayerUnit alloc] init];
    [engine attachNode:tone];
    
    //let mixer = engine.mainMixerNode
    //[engine connect(tone, to: mixer, format: format)
    [engine connect:tone to:engine.mainMixerNode format:format];
    NSError*error;
    [engine startAndReturnError:&error];
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
    
    
   // main2();
    
//    xpc_connection_t conn = xpc_connection_create_mach_service( "com.yourname.product.service", dispatch_get_main_queue(), XPC_CONNECTION_MACH_SERVICE_LISTENER );
//    xpc_connection_set_event_handler( conn, ^( xpc_object_t client ) {
//
//        xpc_connection_set_event_handler( client, ^(xpc_object_t object) {
//            NSLog( @"received message: %s", xpc_copy_description( object ) );
//
//            xpc_object_t reply = xpc_dictionary_create_reply( object );
//            xpc_dictionary_set_string( reply, "reply", "Back from the service" );
//
//            xpc_connection_t remote = xpc_dictionary_get_remote_connection( object );
//            xpc_connection_send_message( remote, reply );
//        } );
//
//        xpc_connection_resume( client );
//    }) ;
//
//    xpc_connection_resume( conn );
    
    initialize_audio_engine();
    GCDWebServer* webServer = [[GCDWebServer alloc] init];
    
    // Add a handler to respond to GET requests on any URL
    [webServer addDefaultHandlerForMethod:@"GET"
                             requestClass:[GCDWebServerRequest class]
                             processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                 size_t payload_len = 4;
                                 uint8_t payload[] = {104,101,108,108};
                                 NSString* d = [request.query objectForKey:@"payload"];
                                 NSLog(@"%@",d);
                                 
                                 encode_to_audio((uint8_t*)[d UTF8String], [d length]  );
                                 return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
                                 
                             }];
    
    [webServer runWithPort:8080 bonjourName:nil];
    [NSApp run];
    quiet_encoder_destroy(e);
    free(encodeopt);
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

