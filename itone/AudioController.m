//
//  AudioController.m
//  itone
//
//  Created by Jonathan S Baker on 04/11/2015.
//  Copyright © 2015 Jonathan S Baker. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <math.h>

// Framework includes
#import <AVFoundation/AVAudioSession.h>

#import "AudioController.h"
#import "SinSynth.h"

//scales
double cMajPent[16] = {163.5, 183.5, 206, 245, 275, 327, 367.1, 412, 490, 550, 654.1, 734.2, 824.1, 980, 1100, 1308.3};

//bit boards
UInt16 bitColumns[16];
UInt16 setMask[16];
UInt16 clearMask[16];

@interface AudioController()
@property SinSynth *synth;
@property (weak) NSTimer* timer;
@property int beatCount;

- (void)timerMethod:(NSTimer*)theTimer;
- (NSDictionary*) userInfo;

@end

@implementation AudioController

- (id) init
{
    if(self = [super init])
    {
        NSLog(@"Init audio controller");
        for (int i = 0; i < 16; i++)
        {
            setMask[i] = 0ULL;
            clearMask[i] = 0ULL;
        }
        for (int i = 0; i < 16; i++)
        {
            setMask[i] |= (1ULL << i);
            clearMask[i] = ~setMask[i];
        }
        
        _synth = [[SinSynth alloc] init];
        [_synth setNotes:cMajPent];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                          target:self selector:@selector(timerMethod:)
                                                        userInfo:NULL repeats:YES];
        self.timer = timer;
    }
    return self;
}
- (void) toggleTone:(int)index
{
    int colIndex = floor(index/16);
    int rowIndex = index%16;
    if((1ULL << rowIndex) & bitColumns[colIndex])
    {
        //clear
        bitColumns[colIndex] &= (clearMask[rowIndex]);
    }
    else
    {
        //set
        bitColumns[colIndex] |= (setMask[rowIndex]);
    }
}

- (void)timerMethod:(NSTimer *)theTimer
{
    for (int i = 0; i < 16; i++)
    {
        if ((1ULL << i) & bitColumns[self.beatCount])
        {
            [_synth playNote:i];
        }
    };
    self.beatCount = self.beatCount == 15 ? 0:self.beatCount + 1;
}

- (NSDictionary *)userInfo
{
    return @{ @"StartDate" : [NSDate date] };
}
@end

