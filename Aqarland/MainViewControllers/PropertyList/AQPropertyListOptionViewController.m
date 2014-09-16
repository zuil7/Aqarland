//
//  AQPropertyListOptionViewController.m
//  Aqarland
//
//  Created by Louise on 16/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQPropertyListOptionViewController.h"

@interface AQPropertyListOptionViewController ()

@end

@implementation AQPropertyListOptionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Property List"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIImage *backImage = [UIImage imageNamed:iBackArrowImg];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0,0,22,32);
        [backBtn setImage:backImage forState:UIControlStateNormal];
        
        [backBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
    }
}

////////////////////////////////////
#pragma mark - Action
////////////////////////////////////

-(IBAction)option_touchedup_inside:(id)sender
{
    if([sender tag]==0)
    {
    
    }else
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}
@end
