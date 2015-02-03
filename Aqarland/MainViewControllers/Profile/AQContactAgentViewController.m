//
//  AQContactAgentViewController.m
//  Aqarland
//
//  Created by Louise on 29/1/15.
//  Copyright (c) 2015 Louise. All rights reserved.
//

#import "AQContactAgentViewController.h"
#import "ChatView.h"
#import "messages.h"
#import <MessageUI/MessageUI.h>
@interface AQContactAgentViewController ()<MFMailComposeViewControllerDelegate>

@property(nonatomic,strong) UIImage *agentAvatar;
@end

@implementation AQContactAgentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeHeaderBar];
    [self fillInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////
#pragma - Logic
///////////////////////
-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Property Details"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
        [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,RGB(255, 255, 255), NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
        /*
        UIImage *backImage = [UIImage imageNamed:iBackArrowImg];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0,0,22,32);
        [backBtn setImage:backImage forState:UIControlStateNormal];
        
        [backBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        */
    }
   
}
-(void) fillInfo
{
    NSLog(@"propertyDetails %@",self.propertyDetails);
    NSLog(@"userProfile %@",self.userProfile);
    

    [self.telLbl setText:self.userProfile[@"phoneNumber"]];
    
    
    PFUser *user=(PFUser *)self.propertyDetails.user;
    [self.navigationItem setTitle:user[@"name"]];
   
    PFUser *user1=[PFUser currentUser];
    if([user1.objectId isEqualToString:user.objectId])
    {
        [self.EmailBtn setEnabled:NO];
        [self.CallBtn setEnabled:NO];
        [self.chatWithAgentBtn setHidden:YES];
    }else
    {
        [self.EmailBtn setEnabled:YES];
        [self.CallBtn setEnabled:YES];
        [self.chatWithAgentBtn setHidden:NO];
    }
    [self.emailLbl setText:user[@"email"]];
    PFFile *imageFile = self.userProfile[@"userAvatar"];
    NSData *imageData = [imageFile getData];
    UIImage *image = [UIImage imageWithData:imageData];
    [self.avatarImg setImage:image forState:UIControlStateNormal];
    [self.avatarImg setImage:image forState:UIControlStateHighlighted];
    [self.avatarImg setImage:image forState:UIControlStateSelected];
    self.agentAvatar=image;
    
    [self.addressTextView setText:[NSString stringWithFormat:@"%@",self.userProfile[@"address"]]];
}

-(IBAction)call_touchedup_Inside:(id)sender
{
  
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] )
    {
        NSLog(@"self.contactNumberText %@",self.userProfile[@"phoneNumber"]);
        NSString *callStr=[NSString stringWithFormat:@"telprompt://%@",self.userProfile[@"phoneNumber"]];
        NSURL *url = [NSURL URLWithString:callStr];
        [[UIApplication sharedApplication] openURL:url];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation
                                                        message:@"Device cannot call"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }

}
-(IBAction)email_touchedup_Inside:(id)sender
{
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       NSString *emailTitle = @"";
                       // Email Content
                       NSString *messageBody = @"";
                       // To address
                       NSArray *toRecipents;
                       if([self.emailLbl.text length]==0)
                       {
                           toRecipents = [NSArray arrayWithObject:@""];
                       }else
                       {
                           toRecipents = [NSArray arrayWithObject:self.emailLbl.text];
                       }
                       MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                       if ([MFMailComposeViewController canSendMail])
                       {
                           mc.mailComposeDelegate = self;
                           [mc setToRecipients:toRecipents];
                           [mc setSubject:emailTitle];
                           [mc setMessageBody:messageBody isHTML:NO];
                           
                           [GlobalInstance.navController presentViewController:mc animated:YES completion:NULL];
                       }
                   });
    

}
-(IBAction)chatAgent_touchedup_Inside:(id)sender
{
    PFUser *user1 = [PFUser currentUser];
    PFUser *user2 = (PFUser *)self.propertyDetails.user;
    NSString *roomId = StartPrivateChat(user1, user2);
    //        //---------------------------------------------------------------------------------------------------------------------------------------------
    ChatView *chatView = [[ChatView alloc] initWith:roomId];
    chatView.agentAvatar=self.agentAvatar;
    chatView.userAgent=user2;
    [self.navigationController pushViewController:chatView animated:YES];

}



-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation
                                                            message:@"Mail Successfully Sent" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
            
            [alert show];
        }
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [GlobalInstance.navController dismissViewControllerAnimated:YES completion:NULL];
}
@end
