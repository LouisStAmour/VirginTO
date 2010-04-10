//
//  iPhoneStreamingPlayerViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface iPhoneStreamingPlayerViewController : UIViewController
{
	IBOutlet UITextField *textField;
	IBOutlet UIButton *button;
	IBOutlet UIButton *muteButton;
	IBOutlet UIButton *muteButton30s;
	AudioStreamer *streamer;
	NSTimer *muteTimer;
	
	UILabel *metadata;
	//UILabel *metadata2;
	//UILabel *bitrate;
	
	Boolean muted;
}

@property (nonatomic, retain) IBOutlet UILabel *metadata;
@property (nonatomic, retain) NSTimer *muteTimer;
//@property (nonatomic, retain) IBOutlet UILabel *metadata2;
//@property (nonatomic, retain) IBOutlet UILabel *bitrate;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)muteButtonPressed:(id)sender;
- (IBAction)mute30sButtonPressed:(id)sender;
- (void)muteFor:(int)seconds;
- (void)unmute;

- (void)bitrateUpdated:(NSNumber *)br;
- (void)metaDataUpdated:(NSString *)metaData;

@end

