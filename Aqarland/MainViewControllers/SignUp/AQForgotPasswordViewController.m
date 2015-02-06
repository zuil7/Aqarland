//
//  AQForgotPasswordViewController.m
//  Aqarland
//
//  Created by Louise on 5/2/15.
//  Copyright (c) 2015 Louise. All rights reserved.
//

#import "AQForgotPasswordViewController.h"

@interface AQForgotPasswordViewController ()

@end

@implementation AQForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeHeaderBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
////////////////////////
#pragma mark - Logic
////////////////////////
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
-(void) customizeHeaderBar
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"Reset Password"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIImage *backImage = [UIImage imageNamed:iCloseImg];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0,0,22,22);
        [backBtn setImage:backImage forState:UIControlStateNormal];
        
        [backBtn addTarget:self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
    }
    
}
-(BOOL) checkTextField
{
    if (self.emailAddTxtField.text.length!=0)
    {
        return 1;
    }else
    {
        return 0;
    }
    
}
- (void)closePressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////
#pragma mark - Action
////////////////////////
-(IBAction)resetPassword_touchedup_inside:(id)sender
{
    [self.emailAddTxtField resignFirstResponder];
    if([self checkTextField])
    {
        if([self NSStringIsValidEmail:self.emailAddTxtField.text])
        {
            [PFUser requestPasswordResetForEmailInBackground:self.emailAddTxtField.text
                                                       block:^(BOOL succeeded, NSError *error)
             {
                 if(succeeded)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation
                                                                     message:@"Please check your email"
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }else
                 {
                     [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
                 }
             }];
        }else
        {
             [GlobalInstance showAlert:iInformation message:@"Invalid email format"];
        }
    }else
    {
          [GlobalInstance showAlert:iInformation message:@"Please fill out all the textfield to proceed"];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self closePressed:nil];
}

@end
