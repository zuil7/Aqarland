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
#import "FHSTwitterEngine.h"

@interface AQViewController ()<UIActionSheetDelegate,PFLogInViewControllerDelegate>

@property(nonatomic,strong) IIViewDeckController *viewDeckVC;
@property(nonatomic,strong) AQHomeViewController *homeVC;
@property(nonatomic,strong) AQSideMenuViewController *sideMenuVC;

@property(nonatomic,strong) PFLogInViewController *logInController;
@property(nonatomic,strong) CustomLoginVC *customLoginVC;
@property(nonatomic,strong) AQSignUpViewController *signUpVC;
@property(strong,nonatomic) UINavigationController *HomeVcNav;

@property (strong, nonatomic) NSArray *twitterAccounts;
@end

@implementation AQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    GlobalInstance.navController=self.navigationController;
    
   // [self ParseLoginCustomizationControllers];
    
    
    [self LoadViewControllers];
#warning mark Put NSUSERDEFAULTS HERE
    BOOL check=0;
    if(check)
    {
        [self.navigationController pushViewController:self.viewDeckVC animated:NO];
    }
#warning mark Put NSUSERDEFAULTS HERE
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void) ParseLoginCustomizationControllers
{
    self.customLoginVC = [[CustomLoginVC alloc] init];
    self.customLoginVC.delegate = self;
    self.customLoginVC.facebookPermissions = @[@"user_about_me", @"user_birthday", @"email"];
    self.customLoginVC.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;
    
    self.signUpVC=[GlobalInstance loadStoryBoardId:sSignUpVC];
    //self.customLoginVC.signUpController = nil;
    [self.view addSubview:self.customLoginVC.view];

    [self.customLoginVC.customSignUpBtn addTarget:self action:@selector(showSignUp:) forControlEvents:UIControlEventTouchUpInside];
    //    self.logInController=[[PFLogInViewController alloc] init];
    //    [self.logInController setDelegate:self];
    //    self.logInController.fields =  PFLogInFieldsUsernameAndPassword
    //    | PFLogInFieldsLogInButton
    //    | PFLogInFieldsSignUpButton
    //    | PFLogInFieldsPasswordForgotten
    //    | PFLogInFieldsFacebook
    //    | PFLogInFieldsTwitter;
    //
    //    [self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 120.0f, 40.0f)];
    
}*/
#pragma mark - Logic
-(void) LoadViewControllers
{
    
    
    self.homeVC =[GlobalInstance loadStoryBoardId:sHomeVC];
    self.sideMenuVC =[GlobalInstance loadStoryBoardId:sSideMenuVC];
    self.HomeVcNav = [[UINavigationController alloc] initWithRootViewController:self.homeVC];
    
    self.viewDeckVC=[[IIViewDeckController alloc] init];
    self.viewDeckVC.leftSize=70.0f;
    self.viewDeckVC.leftController=self.sideMenuVC;
    self.viewDeckVC.rightController=nil;
    self.viewDeckVC.centerController=self.HomeVcNav;
    
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
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
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
            NSLog(@"userProfile %@",userProfile);
            
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request createAccountViaFB:userProfile];
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
            [GlobalInstance showAlert:iErrorInfo message:[error description]];
        }
    }];
}

-(void) TwitterRequestInfo
{

}

#pragma mark - Action
-(IBAction)login_touchedup_inside:(id)sender
{
    if (self.viewDeckVC)
    {
        [self.navigationController pushViewController:self.viewDeckVC animated:YES];
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
                 [self.navigationController pushViewController:self.viewDeckVC animated:YES];
            }
            else
            {
              [self facebookRequestInfo];
              //[self.navigationController pushViewController:self.viewDeckVC animated:YES];
                //           
            }
        }];
}
-(IBAction)loginTwitter_touchedup_inside:(id)sender
{
    __weak AQViewController *weakSelf = self;
    [PFTwitterUtils getTwitterAccounts:^(BOOL accountsWereFound, NSArray *twitterAccounts) {
        [weakSelf handleTwitterAccounts:twitterAccounts];
    }];
}
-(IBAction)signUp_touchedup_inside:(id)sender
{
    self.signUpVC=[GlobalInstance loadStoryBoardId:sSignUpVC];
    [self.navigationController pushViewController:self.signUpVC animated:YES];
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}

#pragma mark - Twitter Login Methods

- (void)handleTwitterAccounts:(NSArray *)twitterAccounts
{
    NSLog(@"twitterAccounts %@",twitterAccounts);
    switch ([twitterAccounts count]) {
        case 0:
        {
            [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:kTwitterKey andSecret:kTwitterSecret];
            [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
            UIViewController *loginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success) {
                if (success) {
                    //[NTRTwitterClient loginUserWithTwitterEngine];
                    ParseLayerService *request=[[ParseLayerService alloc] init];
                    [request loginUserWithTwitterEngine];
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
                         [GlobalInstance showAlert:iErrorInfo message:[error description]];
                     }];
                }
            }];
            [self presentViewController:loginController animated:YES completion:nil];
            
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
         [GlobalInstance showAlert:iErrorInfo message:[error description]];
     }];
}

- (void)loginUserWithTwitterEngine
{

}
#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self onUserTwitterAccountSelection:self.twitterAccounts[buttonIndex]];
    }
}

@end
