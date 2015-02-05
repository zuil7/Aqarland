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
-(void) customizeHeaderBar
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"Reset Password"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
    
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
