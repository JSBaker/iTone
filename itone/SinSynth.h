//
//  SinSynth.h
//  itone
//
//  Created by Jonathan S Baker on 06/11/2015.
//  Copyright © 2015 Jonathan S Baker. All rights reserved.
//

#ifndef SinSynth_h
#define SinSynth_h

@interface SinSynth : NSObject
- (void)playNote:(int)index;
- (void)setNotes:(double*)notes;
@end

#endif /* SinSynth_h */
