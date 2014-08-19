//
//  AQAddPropertyViewController.m
//  Aqarland
//
//  Created by Louise on 14/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQAddPropertyViewController.h"
#import "AQPropertyDetailsViewController.h"


@interface AQAddPropertyViewController ()

@property(nonatomic,strong) NSMutableDictionary *propertyDictionary;
@property(nonatomic,strong) AQPropertyDetailsViewController *propertyDetailsVC;

@end

@implementation AQAddPropertyViewController

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
    [self customizeHeaderBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Add Property"];
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
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)])
    {
        UIImage *forwardImage = [UIImage imageNamed:iForwardArrowImg];
        UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        forwardBtn.frame = CGRectMake(0,0,22,32);
        [forwardBtn setImage:forwardImage forState:UIControlStateNormal];
        
        [forwardBtn addTarget:self action:@selector(goToPropertyDetails:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];
        [self.navigationItem setRightBarButtonItem:barButtonItem];
        
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void) goToPropertyDetails:(id) sender
{
    if([self checkTextField])
    {
        self.propertyDictionary=[[NSMutableDictionary alloc] init];
        self.propertyDictionary[@"unit"] = self.unitTxtField.text;
        self.propertyDictionary[@"houseNum"] = self.houseNumTxtField.text;
        self.propertyDictionary[@"bldg"] = self.bldgTxtField.text;
        self.propertyDictionary[@"street"] = self.streetTxtField.text;
        self.propertyDictionary[@"city"] = self.cityTxtField.text;
        self.propertyDictionary[@"postcode"] = self.postCodeTxtField.text;
        
        self.propertyDetailsVC=[GlobalInstance loadStoryBoardId:sAddPropertyDetailsVC];
        self.propertyDetailsVC.propertyAddress=self.propertyDictionary;
        [self.navigationController pushViewController:self.propertyDetailsVC animated:YES];
    }else
    {
        [GlobalInstance showAlert:iInformation message:@"Please fill out all the textfield to proceed"];
    }
    
}

-(BOOL) checkTextField
{
    if (self.unitTxtField.text.length!=0 &&
        self.houseNumTxtField.text.length!=0 &&
        self.bldgTxtField.text.length!=0 &&
        self.streetTxtField.text.length!=0 &&
        self.cityTxtField.text.length!=0 &&
        self.postCodeTxtField.text.length!=0 ) {
        return 1;
    }else
    {
        return 0;
    }
    
}



@end
