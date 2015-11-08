//
//  SinSynth.m
//  itone
//
//  Created by Jonathan S Baker on 06/11/2015.
//  Copyright © 2015 Jonathan S Baker. All rights reserved.
//
#include <math.h>

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>

#import "SinSynth.h"

double frequencies[16] = {16.35, 18.35, 20.6, 24.5, 27.5, 32.7, 36.71, 41.2, 49, 55, 65.41, 73.42, 82.41, 98, 110, 130.83};
double thetas[16];
double envelopes[16];
double amplitude = 1;

static OSStatus renderAudio(void *inRefCon,
                           AudioUnitRenderActionFlags *ioActionFlags,
                           const AudioTimeStamp *inTimeStamp,
                           UInt32 inBusNumber,
                           UInt32 inNumberFrames,
                           AudioBufferList *ioData)

{
    double toneAmplitude = 0.0625;
    
    const int channel = 0;
    Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    
    for (UInt32 frame = 0; frame < inNumberFrames; frame++)
    {
        double frameValue = 0;
        for (int i = 0; i < 16; i++)
        {
            if (envelopes[i] > 0)
            {
                frameValue += sin(thetas[i]) * toneAmplitude * envelopes[i] * amplitude;
                thetas[i] += 2.0 * M_PI * frequencies[i] / 44100;
                if (thetas[i] > 2.0 * M_PI)
                {
                    thetas[i] -= 2.0 * M_PI;
                }
                envelopes[i] -= (double)1.0/(1*44100);
            }
        }
        buffer[frame] = frameValue;
    }
    return noErr;
}

@interface SinSynth();
@property AudioUnit audioUnit;
-(void)setupAudioUnit;
@end

@implementation SinSynth

- (id) init
{
    if(self = [super init])
    {
        [self setupAudioUnit];
        
        OSStatus err = AudioOutputUnitStart(_audioUnit);
        if (err) NSLog(@"couldn't start AURemoteIO: %d", (int)err);
    }
    return self;
}

-(void) setupAudioUnit
{
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &desc);
    NSAssert(defaultOutput, @"Can't find default output");
    
    // Create a new unit based on this that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &_audioUnit);
    NSAssert1(_audioUnit, @"Error creating unit: %hd", err);
    
    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = renderAudio;
    input.inputProcRefCon = (__bridge void * _Nullable)(self);//NULL;
    err = AudioUnitSetProperty(_audioUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);
    
    // Set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = 44100;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty (_audioUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
}

- (void)setNotes:(double*)notes
{
    for (int i = 0; i < 16; i++)
    {
        frequencies[i] = notes[i];
    }
}

- (void)playNote:(int)index
{
    envelopes[index] = 1;
}

@end

