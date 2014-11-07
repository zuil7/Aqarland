//
//  AQFilterProperTypeVC.h
//  Aqarland
//
//  Created by Rey Jenald Pena on 11/4/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AQFilterProperTypeVCDelegate <NSObject>
@optional
- (void)filterPropertyTypeVCDidEndPresenting;
@end
@interface AQFilterProperTypeVC : UIViewController

@property (nonatomic,strong) UIImage *imageScreen;

@property (nonatomic, unsafe_unretained) id<AQFilterProperTypeVCDelegate> filterDelegate;


@end
