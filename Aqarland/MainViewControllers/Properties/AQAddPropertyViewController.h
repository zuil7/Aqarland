//
//  AQAddPropertyViewController.h
//  Aqarland
//
//  Created by Louise on 14/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PropertyList;

@interface AQAddPropertyViewController : UIViewController

@property (strong, nonatomic) PropertyList *propertyDetails;
@property (weak, nonatomic) IBOutlet UITextField *unitTxtField;
@property (weak, nonatomic) IBOutlet UITextField *houseNumTxtField;
@property (weak, nonatomic) IBOutlet UITextField *bldgTxtField;
@property (weak, nonatomic) IBOutlet UITextField *streetTxtField;
@property (weak, nonatomic) IBOutlet UITextField *cityTxtField;
@property (weak, nonatomic) IBOutlet UITextField *postCodeTxtField;
@property (strong, nonatomic) NSMutableDictionary *propertyDetailsDict;
@property (assign, nonatomic) NSInteger nIndex;

@end
