//
//  AQPropertyDetailsViewController.h
//  Aqarland
//
//  Created by Louise on 15/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQPropertyDetailsViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *propertyAddress;

@property (weak, nonatomic) IBOutlet UILabel *propertyTypeLbl;
@property (weak, nonatomic) IBOutlet UITextField *areaTxtField;
@property (weak, nonatomic) IBOutlet UITextField *nBedroomsTxtField;
@property (weak, nonatomic) IBOutlet UITextField *nBathsTxtField;
@property (weak, nonatomic) IBOutlet UITextField *amenitiesTxtField;
@property (weak, nonatomic) IBOutlet UITextView *descTxtView;
@end
