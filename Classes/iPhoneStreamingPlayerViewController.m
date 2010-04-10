//
//  iPhoneStreamingPlayerViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//

#import "iPhoneStreamingPlayerViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>

@implementation iPhoneStreamingPlayerViewController
@synthesize metadata;
//@synthesize metadata2;
//@synthesize bitrate;

#pragma mark -
#pragma mark AudioStream Callback Functions
- (void)bitrateUpdated:(NSNumber *)br 
{
	//bitrate.text = [br stringValue];
}

- (void)metaDataUpdated:(NSString *)metaData 
{
	NSArray *listItems = [metaData componentsSeparatedByString:@";"];
	
	if ([listItems count] > 0) {
		//metadata.text = [listItems objectAtIndex:0];
		//NSLog(@"%@", metaData);
		
		if ([[listItems objectAtIndex:0] hasPrefix:@"StreamTitle='<?xml version=\"1.0\" encoding=\"UTF-8\" ?><nowplaying><artist><id></id>"]) {
			metadata.text = @"Ad or Live Content";
		} else {
			NSScanner *theScanner = [NSScanner scannerWithString:[listItems objectAtIndex:0]];
			NSString *artist, *album, *track;
			[theScanner scanUpToString:@"<name><![CDATA[" intoString:NULL];
			[theScanner scanUpToString:@"]]></name>" intoString:&artist];
			[theScanner scanUpToString:@"<name><![CDATA[" intoString:NULL];
			[theScanner scanUpToString:@"]]></name>" intoString:&album];
			[theScanner scanUpToString:@"<name><![CDATA[" intoString:NULL];
			[theScanner scanUpToString:@"]]></name>" intoString:&track];
			metadata.text = [NSString stringWithFormat:@"Track: %@\nArtist: %@\nAlbum: %@", track, artist, album];
			if (muted) {
				muted = NO;
				[streamer setVolume:1.0];
				[muteButton setTitle:@"Magic Mute" forState:UIControlStateNormal];
			}
		}
	}
	//if ([listItems count] > 1) {
	//	metadata2.text = [listItems objectAtIndex:1];
	//}
}

- (IBAction)muteButtonPressed:(id)sender {
	if (muted) {
		muted = NO;
		[streamer setVolume:1.0];
		[muteButton setTitle:@"Magic Mute" forState:UIControlStateNormal];
	} else {
		muted = YES;
		[streamer setVolume:0.0];
		[muteButton setTitle:@"Unmute?" forState:UIControlStateNormal];
	}
}

- (void)streamError  
{
	metadata.text = @"Stream Error.";
}

- (void)setButtonImage:(UIImage *)image
{
	[button.layer removeAllAnimations];
	[button
		setImage:image
		forState:0];
}

- (void)viewDidLoad
{
	UIImage *image = [UIImage imageNamed:@"playbutton.png"];
	[self setButtonImage:image];
	muted = NO;
}

- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];

	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];

	[CATransaction commit];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

- (IBAction)buttonPressed:(id)sender
{
	if (!streamer)
	{
		[textField resignFirstResponder];
		
			NSString *escapedValue =
				[(NSString *)CFURLCreateStringByAddingPercentEscapes(
					nil,
					(CFStringRef)[textField text],
					NULL,
					NULL,
					kCFStringEncodingUTF8)
				autorelease];

		NSURL *url = [NSURL URLWithString:escapedValue];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[streamer
			addObserver:self
			forKeyPath:@"isPlaying"
			options:0
			context:nil];
		
		[streamer setDelegate:self];
		[streamer setDidUpdateMetaDataSelector:@selector(metaDataUpdated:)];
		[streamer setDidErrorSelector:@selector(streamError)];
		[streamer setDidDetectBitrateSelector:@selector(bitrateUpdated:)];
		
		[streamer start];

		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];

		[self spinButton];
	}
	else
	{
		[button.layer removeAllAnimations];
		[streamer stop];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
	change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		if ([(AudioStreamer *)object isPlaying])
		{
			[self
				performSelector:@selector(setButtonImage:)
				onThread:[NSThread mainThread]
				withObject:[UIImage imageNamed:@"stopbutton.png"]
				waitUntilDone:NO];
			[(AudioStreamer *)object setVolume:1.0];
		}
		else
		{
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;

			[self
				performSelector:@selector(setButtonImage:)
				onThread:[NSThread mainThread]
				withObject:[UIImage imageNamed:@"playbutton.png"]
				waitUntilDone:NO];
		}

		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
		context:context];
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
	[self buttonPressed:sender];
	return NO;
}

@end
