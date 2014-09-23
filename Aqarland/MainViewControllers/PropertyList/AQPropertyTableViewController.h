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
- (void)didtapcell:(int) nIdx :(NSString *) cityStr;
@end

@interface AQPropertyTableViewController : PFQueryTableViewController

@property (nonatomic,strong) NSString *flagStr;
@property (nonatomic,strong) NSString *StreetStr;
@property (nonatomic, unsafe_unretained) id<PropertyTableViewDelegate> propertyDelegate;

@end
