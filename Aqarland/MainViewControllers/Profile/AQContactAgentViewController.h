//
//  AQContactAgentViewController.h
//  Aqarland
//
//  Created by Louise on 29/1/15.
//  Copyright (c) 2015 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyList.h"

@interface AQContactAgentViewController : UIViewController

@property (nonatomic,assign) NSDictionary *userProfile;
@property (strong, nonatomic) PropertyList *propertyDetails;


@property (weak, nonatomic) IBOutlet UIButton *EmailBtn;
@property (weak, nonatomic) IBOutlet UIButton *CallBtn;
@property (weak, nonatomic) IBOutlet UIButton *avatarImg;
@property (weak, nonatomic) IBOutlet UILabel *telLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UIButton *chatWithAgentBtn;

@end
