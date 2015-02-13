//
//  AQCreateAccountViewController.h
//  Aqarland
//
//  Created by Louise on 1/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQCreateAccountViewController : UIViewController
@property (strong, nonatomic) NSMutableDictionary *placeDict;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *eAddressTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *pNumberTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *pPasswordTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *cPasswordTxtFld;
@property (weak, nonatomic) IBOutlet UILabel *userType;

@end
