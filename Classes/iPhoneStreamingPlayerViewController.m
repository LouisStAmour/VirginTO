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
