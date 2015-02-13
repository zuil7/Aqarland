//
//  AQCreateAccountViewController.m
//  Aqarland
//
//  Created by Louise on 1/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQCreateAccountViewController.h"
#import "RMPickerViewController.h"

@interface AQCreateAccountViewController ()<RMPickerViewControllerDelegate>

@property(nonatomic,strong) NSArray *userTypeArr;


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
    self.userTypeArr=[NSArray arrayWithObjects:@"Seller",@"Agent", nil];

    
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
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        /*self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"left", nil) style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(popViewControllerAnimated:)];*/
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
        [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,RGB(255, 255, 255), NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
//        UIImage *backButtonImage = [UIImage imageNamed:iBackArrowImg];
//        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        backBtn.frame = CGRectMake(0,0,22,32);
//        [backBtn setImage:backButtonImage forState:UIControlStateNormal];
//        
//        [backBtn addTarget:self.viewDeckController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
//        [self.navigationItem setLeftBarButtonItem:barButtonItem];
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
        ![self.userType.text isEqualToString:@"Type"] &&
        self.pPasswordTxtFld.text.length!=0 &&
        self.cPasswordTxtFld.text.length!=0) {
        return 1;
    }else
    {
        return 0;
    }
    
}

#pragma mark - Action
-(IBAction) userType_touchedup_inside:(id) sender
{
    RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    pickerVC.delegate = self;
    
    //You can enable or disable bouncing and motion effects
    //pickerVC.disableBouncingWhenShowing = YES;
    //pickerVC.disableMotionEffects = YES;
    
    [pickerVC show];
}
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
            parameters[@"SellerType"]=self.userType.text;
            parameters[@"loginType"]=mManualLogin;
            
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request signUp:parameters];
            [request setCompletionBlock:^(id results)
            {
                [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];

                if ([results boolValue]==1)
                {
                    //[GlobalInstance showAlert:iInformation message:@"Successfuly Registered"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation
                                                                    message:@"Successfuly Registered"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];

                }
            }];
            [request setFailedBlock:^(NSError *error)
            {
                [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
            }];
        }
    }else
    {
        [GlobalInstance showAlert:iInformation message:@"Please fill out all the textfield to proceed"];
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

////////////////////////
#pragma mark - RMPickerViewController Delegates
////////////////////////
- (void)pickerViewController:(RMPickerViewController *)vc didSelectRows:(NSArray *)selectedRows
{
    //    selectedIdx=0;
    int idx=[[selectedRows objectAtIndex:0] intValue];
    //    selectedIdx=idx + 1;
    NSString *selectedStr=[self.userTypeArr objectAtIndex:idx];
    [self.userType setText:selectedStr];
        
}

- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc {
    NSLog(@"Selection was canceled");
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.userTypeArr count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.userTypeArr objectAtIndex:row];
}

@end
