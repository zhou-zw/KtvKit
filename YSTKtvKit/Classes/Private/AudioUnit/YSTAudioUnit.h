//
//  YSTAudioUnit.h
//  Aruts
//
//  Created by Simon Epskamp on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif

@protocol AudioUnitDelegate <NSObject>
- (void)audioUnitPcm:(NSData *)data;//pcm数据
- (void)audioUnitBuffer:(AudioBufferList *)bufferList;//bufferlist
@end

@interface YSTAudioUnit : NSObject {
	AudioComponentInstance audioUnit;
	AudioBuffer tempBuffer; // this will hold the latest data from the microphone
}
@property(nonatomic,strong)id<AudioUnitDelegate>delegate;
@property (readonly) AudioComponentInstance audioUnit;
@property (readonly) AudioBuffer tempBuffer;

- (void) start;
- (void) stop;
- (void) processAudio: (AudioBufferList*) bufferList;
@end

extern YSTAudioUnit* ystAudio;
