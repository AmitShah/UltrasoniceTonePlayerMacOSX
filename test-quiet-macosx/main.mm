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

#pragma once
#if UNITY_METRO
#define EXPORT_API __declspec(dllexport) __stdcall
#elif UNITY_WIN
#define EXPORT_API __declspec(dllexport)
#else
#define EXPORT_API
#endif

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

static int encode_to_wav(const char *out_fname,
                  const quiet_encoder_options *opt) {
    
    SNDFILE *wav = wav_open(out_fname, sample_rate);
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
    
    size_t block_len = 16384/128;
    uint8_t *readbuf = (uint8_t*)malloc(block_len * sizeof(uint8_t));
    size_t samplebuf_len = 16384/128;
    quiet_sample_t *samplebuf = (quiet_sample_t*)malloc(samplebuf_len * sizeof(quiet_sample_t));
    bool done = false;
    if (readbuf == NULL) {
        return 1;
    }
    if (samplebuf == NULL) {
        return 1;
    }
    size_t frame_len = quiet_encoder_get_frame_len(e);
        quiet_encoder_send(e, payload, payload_len);
        ssize_t written = samplebuf_len;
        while (written == samplebuf_len) {
            written = quiet_encoder_emit(e, samplebuf, samplebuf_len);
            if (written > 0) {
                wav_write(wav, samplebuf, written);
                
                
//                AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:playback error:&error ] ;
//                if (audioPlayer == nil)
//                {
//                    NSLog(@"Error creating AVAudioPlayer: %@", error);
//                    return nil;
//                }
//                [audioPlayer play];
                
            }
        }
//    while (!done) {
//        size_t nread = fread(readbuf, sizeof(uint8_t), block_len, payload);
//        if (nread == 0) {
//            break;
//        } else if (nread < block_len) {
//            done = true;
//        }
//
//        size_t frame_len = quiet_encoder_get_frame_len(e);
//        for (size_t i = 0; i < nread; i += frame_len) {
//            frame_len = (frame_len > (nread - i)) ? (nread - i) : frame_len;
//            quiet_encoder_send(e, readbuf + i, frame_len);
//        }
//
//        ssize_t written = samplebuf_len;
//        while (written == samplebuf_len) {
//            written = quiet_encoder_emit(e, samplebuf, samplebuf_len);
//            if (written > 0) {
//                wav_write(wav, samplebuf, written);
//            }
//        }
//    }
    
    quiet_encoder_destroy(e);
    free(readbuf);
    free(samplebuf);
    wav_close(wav);
    
    return 0;
}




extern "C" int EXPORT_API main() {
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
         NSError *error;
         NSURL *wavfile=
         [NSURL fileURLWithPath:@"/Users/amitshah/Downloads/quiet-requirements/encoded.wav"];

         AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:wavfile error:&error];
         NSLog(@"%f", audioPlayer.duration);
         [audioPlayer prepareToPlay];




         [audioPlayer play];
    


    
    return 0;
}


//extern "C" void EXPORT_API generate_waveform(){
//    NSLog(@"HERE");
//};

