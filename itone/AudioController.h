//
//  AudioController.h
//  itone
//
//  Created by Jonathan S Baker on 04/11/2015.
//  Copyright © 2015 Jonathan S Baker. All rights reserved.
//

#ifndef AudioController_h
#define AudioController_h

#import <AudioToolbox/AudioToolbox.h>

@interface AudioController : NSObject

- (void) toggleTone:(int)index;

@end

#endif /* AudioController_h */
