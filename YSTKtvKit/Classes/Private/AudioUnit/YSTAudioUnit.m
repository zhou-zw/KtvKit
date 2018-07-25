//
//  YSTAudioUnit.m
//  Aruts
//
//  Created by Simon Epskamp on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YSTAudioUnit.h"
#import <AudioToolbox/AudioToolbox.h>

#define kOutputBus 0
#define kInputBus 1

YSTAudioUnit* ystAudio;

void checkStatus(int status){
	if (status) {
		printf("Status not 0! %d\n", status);
		exit(1);
	}
}

/**
 This callback is called when new audio data from the microphone is available.
 */
static OSStatus recordingCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData) {
	
	// Because of the way our audio format (setup below) is chosen:
	// we only need 1 buffer, since it is mono
	// Samples are 16 bits = 2 bytes.
	// 1 frame includes only 1 sample
	AudioBuffer buffer;
	buffer.mNumberChannels = 1;
	buffer.mDataByteSize = inNumberFrames * 2;
	buffer.mData = malloc( inNumberFrames * 2 );
	
	// Put buffer in a AudioBufferList
	AudioBufferList bufferList;
	bufferList.mNumberBuffers = 1;
	bufferList.mBuffers[0] = buffer;
	
    // Then:
    // Obtain recorded samples
    OSStatus status;
    status = AudioUnitRender([ystAudio audioUnit], ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
	checkStatus(status);
	
    // Now, we have the samples we just read sitting in buffers in bufferList
	// Process the new data
    [ystAudio processAudio:&bufferList];
	
	// release the malloc'ed data in the buffer we created earlier
	free(bufferList.mBuffers[0].mData);
    return noErr;
}

/**
 This callback is called when the audioUnit needs new data to play through the
 speakers. If you don't have any, just don't write anything in the buffers
 */
//static OSStatus playbackCallback(void *inRefCon,
//                                 AudioUnitRenderActionFlags *ioActionFlags,
//                                 const AudioTimeStamp *inTimeStamp,
//                                 UInt32 inBusNumber,
//                                 UInt32 inNumberFrames,
//                                 AudioBufferList *ioData) {
////    // Notes: ioData contains buffers (may be more than one!)
////    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
////    // much data is in the buffer.
////
//        for (int i=0; i < ioData->mNumberBuffers; i++) { // in practice we will only ever have 1 buffer, since audio format is mono
//        AudioBuffer buffer = ioData->mBuffers[i];
//
////        NSLog(@"  Buffer %d has %d channels and wants %d bytes of data.", i, buffer.mNumberChannels, buffer.mDataByteSize);
//
//        // copy temporary buffer data to output buffer
//        UInt32 size = min(buffer.mDataByteSize, [ystAudio tempBuffer].mDataByteSize); // dont copy more data then we have, or then fits
//        memcpy(buffer.mData, [ystAudio tempBuffer].mData, size);
//        buffer.mDataByteSize = size; // indicate how much data we wrote in the buffer
//
//        NSData *data = [NSData dataWithBytes:buffer.mData length:size];
////        [ystAudio.delegate audioUnit:data];
//        // uncomment to hear random noise
//        /*
//        UInt16 *frameBuffer = buffer.mData;
//        for (int j = 0; j < inNumberFrames; j++) {
//            frameBuffer[j] = rand();
//        }
//        */
//
//    }
//
//    return noErr;
//}

@implementation YSTAudioUnit
@synthesize audioUnit, tempBuffer;

#pragma mark - Life Cycle

/**
 Initialize the audioUnit and allocate our own temporary buffer.
 The temporary buffer will hold the latest data coming in from the microphone,
 and will be copied to the output when this is requested.
 */
- (id) init {
	self = [super init];
	OSStatus status;
	
	// audio unit
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;//去除回声
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	checkStatus(status);
	
	// Enable IO for recording
	UInt32 flag = 1;
	status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, kInputBus, &flag, sizeof(flag));
	checkStatus(status);
	status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, kOutputBus, &flag, sizeof(flag));
	checkStatus(status);
	
	// Describe format
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate			= 44100.00;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 1;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 2;
	audioFormat.mBytesPerFrame		= 2;
	
	// Apply format
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, kOutputBus, &audioFormat, sizeof(audioFormat));
    checkStatus(status);
	status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, kInputBus, &audioFormat, sizeof(audioFormat));
	checkStatus(status);
	
	// Set callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = recordingCallback;
	callbackStruct.inputProcRefCon = self;
	status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, kInputBus, &callbackStruct, sizeof(callbackStruct));
	checkStatus(status);
    
    //不回传耳机
//    callbackStruct.inputProc = playbackCallback;
//    callbackStruct.inputProcRefCon = self;
//    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, kOutputBus, &callbackStruct, sizeof(callbackStruct));
//    checkStatus(status);
	
	// Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
	flag = 0;
	status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, kInputBus, &flag, sizeof(flag));
	
	// Allocate our own buffers (1 channel, 16 bits per sample, thus 16 bits per frame, thus 2 bytes per frame).
	// Practice learns the buffers used contain 512 frames, if this changes it will be fixed in processAudio.
	tempBuffer.mNumberChannels = 1;
	tempBuffer.mDataByteSize = 512 * 2;
	tempBuffer.mData = malloc( 512 * 2 );
	
	// Initialise
	status = AudioUnitInitialize(audioUnit);
	checkStatus(status);
	return self;
}

- (void) dealloc {
    [super	dealloc];
    AudioUnitUninitialize(audioUnit);
    free(tempBuffer.mData);
}

#pragma mark - Public Methods

/**
 Start the audioUnit. This means data will be provided from
 the microphone, and requested for feeding to the speakers, by
 use of the provided callbacks.
 */
- (void) start {
	OSStatus status = AudioOutputUnitStart(audioUnit);
	checkStatus(status);
}

/**
 Stop the audioUnit
 */
- (void) stop {
	OSStatus status = AudioOutputUnitStop(audioUnit);
	checkStatus(status);
//    NSData *audio = [NSData dataWithBytes:tempBuffer.mData length:bufferList->mBuffers[0].mDataByteSize];
}

/**
 Change this funtion to decide what is done with incoming
 audio data from the microphone.
 Right now we copy it to our own temporary buffer.
 */
- (void) processAudio: (AudioBufferList*) bufferList{
	AudioBuffer sourceBuffer = bufferList->mBuffers[0];
	// fix tempBuffer size if it's the wrong size
	if (tempBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
		free(tempBuffer.mData);
		tempBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
		tempBuffer.mData = malloc(sourceBuffer.mDataByteSize);
	}
	
	// copy incoming audio data to temporary buffer
	memcpy(tempBuffer.mData, bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize);
    NSData *data = [NSData dataWithBytes:sourceBuffer.mData length:bufferList->mBuffers[0].mDataByteSize];
    [self.delegate audioUnitPcm:data];
    [self.delegate audioUnitBuffer:bufferList];
}

@end
