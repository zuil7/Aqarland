//
//  AQViewController.m
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQViewController.h"
#import "AQSideMenuViewController.h"
#import "AQHomeViewController.h"
#import "CustomLoginVC.h"
#import "AQSignUpViewController.h"
#import "PFTwitterUtils+NativeTwitter.h"
#import "IQKeyboardManager.h"

@interface AQViewController ()<UIActionSheetDelegate,PFLogInViewControllerDelegate>

@property(nonatomic,strong) IIViewDeckController *viewDeckVC;
@property(nonatomic,strong) AQHomeViewController *homeVC;
@property(nonatomic,strong) AQSideMenuViewController *sideMenuVC;

@property(nonatomic,strong) PFLogInViewController *logInController;
@property(nonatomic,strong) CustomLoginVC *customLoginVC;
@property(nonatomic,strong) AQSignUpViewController *signUpVC;
@property(strong,nonatomic) UINavigationController *ListProperty;


@property (strong, nonatomic) NSArray *twitterAccounts;
@end

@implementation AQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    GlobalInstance.navController=self.navigationController;
    
   // [self ParseLoginCustomizationControllers];
     [[IQKeyboardManager sharedManager] setEnable:YES];
     [self LoadViewControllers];
  

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:YES];
#warning mark Put NSUSERDEFAULTS HERE
    if([self checkUserDefaults])
    {
        //[self LoadDashboard];
        [self.navigationController pushViewController:self.viewDeckVC animated:NO];
        
    }
#warning mark Put NSUSERDEFAULTS HERE
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(BOOL) checkUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"defaults %@",defaults);
    NSString *userName = [defaults objectForKey:userDefaultUserName];
    NSString *loginType = [defaults objectForKey:userDefaultLoginType];
    NSString *emailVerified = [defaults objectForKey:userDefaultEmailVerified];
    NSString *loginFlag = [defaults objectForKey:userDefaultLoginFlag];
    //Logs
    NSLog(@"loginType %@",loginType);
    NSLog(@"userName %@",userName);
    NSLog(@"emailVerified %@",emailVerified);
    NSLog(@"loginFlag %@",loginFlag);
    //logs
    
    BOOL isVerified=[emailVerified boolValue];
    BOOL isLogin=[loginFlag boolValue];
   if([userName length] != 0 &&
      [loginType length] != 0 &&
      isLogin!=0)
   {
       if (isVerified!=0)
       {
           return 1;
       }else
       {
           if([loginType isEqualToString:mTwitterLogin])
           {
               return 1;
           }else if([loginType isEqualToString:mFBLogin])
           {
               return 1;
           }
       }
       
   }else
   {
       return 0;
   }
    return 0;
}
-(void) LoadViewControllers
{
    
    self.homeVC =[GlobalInstance loadStoryBoardId:sHomeVC];
    self.sideMenuVC =[GlobalInstance loadStoryBoardId:sSideMenuVC];
    
    self.ListProperty = [[UINavigationController alloc] initWithRootViewController:self.homeVC];
    self.viewDeckVC=[[IIViewDeckController alloc] init];
    self.viewDeckVC.leftSize=70.0f;
    self.viewDeckVC.leftController=self.sideMenuVC;
    self.viewDeckVC.rightController=nil;
    self.viewDeckVC.centerController=self.ListProperty;
    
}

-(void) facebookRequestInfo
{
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         NSLog(@"result %@",result);
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] init];
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            if (userData[@"email"]) {
                userProfile[@"email"] = userData[@"email"];
            }
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if ([pictureURL absoluteString])
            {
                NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                PFFile *imageFile = [PFFile fileWithData:imageData];
                userProfile[@"imgFile"] = imageFile;
            }
            userProfile[@"loginType"]=mFBLogin;
            
            NSLog(@"userProfile %@",userProfile);
            
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request createAccountViaFB:userProfile];
            [request setCompletionBlock:^(id results)
             {
                 [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                 
                 if (results)
                 {
                     NSLog(@"results %@",results);
                   PFUser *user=results;
                   [self SavedUserDefaults:user];
                   [self.navigationController pushViewController:self.viewDeckVC animated:YES];
                 }
             }];
            [request setFailedBlock:^(NSError *error)
            {
                [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                [GlobalInstance showAlert:iErrorInfo message:[error description]];
            }];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"])
        {
            // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            //[self logoutButtonTouchHandler:nil];
        } else
        {
            [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
            [GlobalInstance showAlert:iErrorInfo message:[error description]];
        }
    }];
}

-(void) SavedUserDefaults :(PFUser *) userInfo
{
    if([userInfo[@"loginType"] isEqualToString:mManualLogin]||
       [userInfo[@"loginType"] isEqualToString:mFBLogin])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
        [defaults setObject:userInfo[@"username"] forKey:userDefaultUserName];
        [defaults setObject:userInfo[@"loginType"] forKey:userDefaultLoginType];
        [defaults setObject:userInfo[@"emailVerified"] forKey:userDefaultEmailVerified];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:userDefaultLoginFlag];
        [defaults synchronize];
        
         //Logs
        NSLog(@"loginType %@",[defaults objectForKey:userDefaultLoginType]);
        NSLog(@"userName %@",[defaults objectForKey:userDefaultUserName]);
        NSLog(@"emailVerified %@",[defaults objectForKey:userDefaultEmailVerified]);
        NSLog(@"loginFlag %@",[defaults objectForKey:userDefaultLoginFlag]);

    }else
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:userInfo[@"username"] forKey:userDefaultUserName];
        [defaults setObject:userInfo[@"loginType"] forKey:userDefaultLoginType];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:userDefaultLoginFlag];
        [defaults synchronize];
        //Logs
        NSLog(@"loginType %@",[defaults objectForKey:userDefaultLoginType]);
        NSLog(@"userName %@",[defaults objectForKey:userDefaultUserName]);
        NSLog(@"emailVerified %@",[defaults objectForKey:userDefaultEmailVerified]);
        NSLog(@"loginFlag %@",[defaults objectForKey:userDefaultLoginFlag]);
        

    }
}
-(void) TwitterRequestInfo
{
    __weak AQViewController *weakSelf = self;
    [PFTwitterUtils getTwitterAccounts:^(BOOL accountsWereFound, NSArray *twitterAccounts) {
        [weakSelf handleTwitterAccounts:twitterAccounts];
    }];
}

-(BOOL) checkTextField
{
    if (self.uETxtField.text.length!=0 &&
        self.uPTxtField.text.length!=0) {
        return 1;
    }else
    {
        return 0;
    }
    
}
////////////////////////////////////
#pragma mark - Action
////////////////////////////////////

-(IBAction)login_touchedup_inside:(id)sender
{
    [self.uETxtField resignFirstResponder];
    [self.uPTxtField resignFirstResponder];

    if([self checkTextField])
    {
            [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request requestLogin:self.uETxtField.text passWord:self.uPTxtField.text];
            [request setCompletionBlock:^(id results)
             {
                 [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                 if (results)
                 {
                     PFUser *user=results;
                     BOOL isVerified=[user[@"emailVerified"] boolValue];
                     if(isVerified==0)
                     {
                          [GlobalInstance showAlert:iInformation message:NSLocalizedString(@"Please Verify Registration", nil)];
                     }else
                     {
                         [self SavedUserDefaults:user];
                         [self.navigationController pushViewController:self.viewDeckVC animated:YES];
                     }
                 }else
                 {
                  [GlobalInstance showAlert:iInformation message:NSLocalizedString(@"Wrong Combination", nil)];
                 }
             }];
            [request setFailedBlock:^(NSError *error)
             {
                 [GlobalInstance showAlert:NSLocalizedString(iErrorInfo, nil) message:[error description]];
             }];
    }else
    {
          [GlobalInstance showAlert:iInformation message:NSLocalizedString(@"Please fill in the fields", nil)];
    }
}

-(IBAction)loginFb_touchedup_inside:(id)sender
{
     NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error)
     {
            if (!user)
            {
                [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                if (!error)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }
            }
            else if (user.isNew)
            {
                [self facebookRequestInfo];
                //NSLog(@"User with facebook signed up and logged in!");
                // [self.navigationController pushViewController:self.viewDeckVC animated:YES];
            }
            else
            {
              //[self facebookRequestInfo];
                if (user)
                {
                     [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                    [self SavedUserDefaults:user];
                    [self.navigationController pushViewController:self.viewDeckVC animated:YES];
                }
                
                
            }
        }];
}
-(IBAction)loginTwitter_touchedup_inside:(id)sender
{
    [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user)
        {
            [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            
        }
        else if (user.isNew)
        {
           [self TwitterRequestInfo];
            
        } else
        {
            if (user)
            {
                [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                [self SavedUserDefaults:user];
                [self.navigationController pushViewController:self.viewDeckVC animated:YES];
            }

        }
    }];
    //[self TwitterRequestInfo];
}
-(IBAction)signUp_touchedup_inside:(id)sender
{
    self.signUpVC=[GlobalInstance loadStoryBoardId:sSignUpVC];
    [self.navigationController pushViewController:self.signUpVC animated:YES];
}
////////////////////////////////////
#pragma mark - PFLogInViewControllerDelegate
////////////////////////////////////

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}

////////////////////////////////////
#pragma mark - Twitter Login Methods
////////////////////////////////////
- (void)handleTwitterAccounts:(NSArray *)twitterAccounts
{
    NSLog(@"twitterAccounts %@",twitterAccounts);
    switch ([twitterAccounts count]) {
        case 0:
        {
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request loginUserWithTwitterEngine];
            [request setCompletionBlock:^(id results)
             {
                 [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                 
                 if (results)
                 {
                     PFUser *user=results;
                     [self SavedUserDefaults:user];
                     [self.navigationController pushViewController:self.viewDeckVC animated:YES];
                 }
             }];
            [request setFailedBlock:^(NSError *error)
             {
                 [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                 [GlobalInstance showAlert:iErrorInfo message:[error description]];
             }];
            
        }
            break;
        case 1:
            [self onUserTwitterAccountSelection:twitterAccounts[0]];
            break;
        default:
            self.twitterAccounts = twitterAccounts;
            [self displayTwitterAccounts:twitterAccounts];
            break;
    }
    
}

- (void)displayTwitterAccounts:(NSArray *)twitterAccounts
{
    __block UIActionSheet *selectTwitterAccountsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account"
                                                                                          delegate:self
                                                                                 cancelButtonTitle:nil
                                                                            destructiveButtonTitle:nil
                                                                                 otherButtonTitles:nil];
    
    [twitterAccounts enumerateObjectsUsingBlock:^(id twitterAccount, NSUInteger idx, BOOL *stop) {
        [selectTwitterAccountsActionSheet addButtonWithTitle:[twitterAccount username]];
    }];
    selectTwitterAccountsActionSheet.cancelButtonIndex = [selectTwitterAccountsActionSheet addButtonWithTitle:@"Cancel"];
    
    [selectTwitterAccountsActionSheet showInView:self.view];
}

- (void)onUserTwitterAccountSelection:(ACAccount *)twitterAccount
{
    //[NTRTwitterClient loginUserWithAccount:twitterAccount];
    ParseLayerService *request=[[ParseLayerService alloc] init];
    [request loginUserWithAccount:twitterAccount];
    [request setCompletionBlock:^(id results)
     {
         [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
         
         if ([results boolValue]==1)
         {
             [self.navigationController pushViewController:self.viewDeckVC animated:YES];
         }
     }];
    [request setFailedBlock:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
         [GlobalInstance showAlert:iErrorInfo message:[error description]];
     }];
}

////////////////////////////////////
#pragma mark - UIActionSheetDelegate Methods
////////////////////////////////////

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self onUserTwitterAccountSelection:self.twitterAccounts[buttonIndex]];
    }
}

@end
