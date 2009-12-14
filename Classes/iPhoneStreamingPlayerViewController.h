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
	AudioStreamer *streamer;
	
	UILabel *metadata;
	UILabel *metadata2;
	UILabel *bitrate;
}

@property (nonatomic, retain) IBOutlet UILabel *metadata;
@property (nonatomic, retain) IBOutlet UILabel *metadata2;
@property (nonatomic, retain) IBOutlet UILabel *bitrate;

- (IBAction)buttonPressed:(id)sender;

- (void)bitrateUpdated:(NSNumber *)br;
- (void)metaDataUpdated:(NSString *)metaData;

@end

