//
//  AQAppDelegate.h
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagesView.h"

@interface AQAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MessagesView *messagesView;

@end
