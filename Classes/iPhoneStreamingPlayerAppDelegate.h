//
//  iPhoneStreamingPlayerAppDelegate.h
//  iPhoneStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iPhoneStreamingPlayerViewController;

@interface iPhoneStreamingPlayerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iPhoneStreamingPlayerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iPhoneStreamingPlayerViewController *viewController;

@end

