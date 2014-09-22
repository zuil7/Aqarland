//
//  AQPropertyTableViewController.h
//  Aqarland
//
//  Created by Louise on 19/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PropertyTableViewDelegate <NSObject>

@optional
- (void)didtapcell:(int) nIdx;
@end

@interface AQPropertyTableViewController : PFQueryTableViewController

@property (nonatomic, unsafe_unretained) id<PropertyTableViewDelegate> propertyDelegate;

@end
