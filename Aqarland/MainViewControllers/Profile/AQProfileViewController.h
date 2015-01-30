//
//  AQProfileViewController.h
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyList.h"

@interface AQProfileViewController : UIViewController

@property (nonatomic,assign) NSDictionary *userProfile;
@property (strong, nonatomic) PropertyList *propertyDetails;

@end
