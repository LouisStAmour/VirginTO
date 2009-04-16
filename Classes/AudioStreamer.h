//
//  AudioStreamer.h
//  StreamingAudioPlayer
//
//  Created by Matt Gallagher on 27/09/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//

#ifdef TARGET_OS_IPHONE			
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif TARGET_OS_IPHONE			

#include <pthread.h>
#include <AudioToolbox/AudioToolbox.h>

#define kNumAQBufs 6			// number of audio queue buffers we allocate
#define kAQBufSize 32 * 1024		// number of bytes in each audio queue buffer
#define kAQMaxPacketDescs 512		// number of packet descriptions in our array

@interface AudioStreamer : NSObject
{
	NSURL *url;
	BOOL isPlaying;
	
@public
	AudioFileStreamID audioFileStream;	// the audio file stream parser

	AudioQueueRef audioQueue;								// the audio queue
	AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];		// audio queue buffers
	
	AudioStreamPacketDescription packetDescs[kAQMaxPacketDescs];	// packet descriptions for enqueuing audio
	
	unsigned int fillBufferIndex;	// the index of the audioQueueBuffer that is being filled
	size_t bytesFilled;				// how many bytes have been filled
	size_t packetsFilled;			// how many packets have been filled

	bool inuse[kNumAQBufs];			// flags to indicate that a buffer is still in use
	bool started;					// flag to indicate that the queue has been started
	bool failed;					// flag to indicate an error occurred
	bool finished;				// flag to inidicate that termination is requested
								// the audio queue is not necessarily complete until
								// isPlaying is also false.
	bool discontinuous;			// flag to trigger bug-avoidance
		
	pthread_mutex_t mutex;			// a mutex to protect the inuse flags
	pthread_cond_t cond;			// a condition varable for handling the inuse flags

	pthread_mutex_t mutex2;			// a mutex to protect the AudioQueue buffer
	CFReadStreamRef stream;
}

@property BOOL isPlaying;

- (id)initWithURL:(NSURL *)newURL;
- (void)start;
- (void)stop;

@end
