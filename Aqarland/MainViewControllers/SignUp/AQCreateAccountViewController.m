//
//  AQCreateAccountViewController.m
//  Aqarland
//
//  Created by Louise on 1/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQCreateAccountViewController.h"

@interface AQCreateAccountViewController ()



@end

@implementation AQCreateAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeHeaderBar];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic
-(void) customizeHeaderBar
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"Create Account"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:23], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"left", nil) style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(popViewControllerAnimated:)];
    }
    
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(BOOL) checkTextField
{
    if (self.fullNameTxtFld.text.length!=0 &&
        self.eAddressTxtFld.text.length!=0 &&
        self.pNumberTxtFld.text.length!=0 &&
        self.pPasswordTxtFld.text.length!=0 &&
        self.cPasswordTxtFld.text.length!=0) {
        return 1;
    }else
    {
        return 0;
    }
    
}

#pragma mark - Action
-(IBAction) done_touchedup_inside:(id)sender
{
    if ([self checkTextField])
    {
        if ([self.pPasswordTxtFld.text isEqualToString:self.cPasswordTxtFld.text])
        {
            [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
            
            NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
            parameters[@"fullname"]=self.fullNameTxtFld.text;
            parameters[@"EmailAddress"]=self.eAddressTxtFld.text;
            parameters[@"PhoneNumber"]=self.pNumberTxtFld.text;
            parameters[@"Password"]=self.pPasswordTxtFld.text;
            parameters[@"Street"]=self.placeDict[@"street"];
            parameters[@"Country"]=self.placeDict[@"country"];
            parameters[@"City"]=self.placeDict[@"city"];
            parameters[@"PostCode"]=self.placeDict[@"postcode"];
            parameters[@"LatLong"]=self.placeDict[@"latlong"];
            parameters[@"loginType"]=mManualLogin;
            
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request signUp:parameters];
            [request setCompletionBlock:^(id results)
            {
                [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];

                if ([results boolValue]==1)
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
            [request setFailedBlock:^(NSError *error)
            {
                [GlobalInstance showAlert:iErrorInfo message:[error description]];
            }];
        }
    }
}

@end
