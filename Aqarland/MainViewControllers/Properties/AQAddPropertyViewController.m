//
//  AQAddPropertyViewController.m
//  Aqarland
//
//  Created by Louise on 14/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQAddPropertyViewController.h"
#import "AQPropertyDetailsViewController.h"
#import "AQPropertyUploadPhoto.h"

@interface AQAddPropertyViewController ()

@property(nonatomic,strong) NSMutableDictionary *propertyDictionary;
@property(nonatomic,strong) AQPropertyDetailsViewController *propertyDetailsVC;
@property(nonatomic,strong) AQPropertyUploadPhoto *propertyUploadVC;

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
    NSLog(@"Property Details %@",self.propertyDetailsDict);
    // Do any additional setup after loading the view.
    [self customizeHeaderBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.propertyDetails)
    {
        self.unitTxtField.text = self.propertyDetails.m_unit;
        self.houseNumTxtField.text = self.propertyDetails.m_houseNumber;
        self.bldgTxtField.text = self.propertyDetails.m_building;
        self.streetTxtField.text = self.propertyDetails.m_street;
        self.cityTxtField.text = self.propertyDetails.m_city;
        self.postCodeTxtField.text = self.propertyDetails.m_postCode;
    }
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
#pragma mark - Setters
////////////////////////////////////

- (void)setPropertyDetails:(PropertyList *)propertyDetails {
    _propertyDetails = propertyDetails;
}

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
        
        [forwardBtn addTarget:self action:@selector(goToUploadImage:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];
        [self.navigationItem setRightBarButtonItem:barButtonItem];
        
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void) goToUploadImage:(id) sender
{
    if([self checkTextField])
    {
        self.propertyDetailsDict[@"unit"] = self.unitTxtField.text;
        self.propertyDetailsDict[@"houseNum"] = self.houseNumTxtField.text;
        self.propertyDetailsDict[@"bldg"] = self.bldgTxtField.text;
        self.propertyDetailsDict[@"street"] = self.streetTxtField.text;
        self.propertyDetailsDict[@"city"] = self.cityTxtField.text;
        self.propertyDetailsDict[@"postcode"] = self.postCodeTxtField.text;
        
        if(self.propertyDetails)
        {
            
            [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request updatePropertyList:self.propertyDetails withDetails:self.propertyDetailsDict];
            [request setCompletionBlock:^(id success)
            {
                    [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
            
                    if ([success boolValue])
                    {
                                 self.propertyUploadVC=[GlobalInstance loadStoryBoardId:sPropertyUploadVC];
                                 self.propertyUploadVC.propertyObjID=self.propertyDetails.m_objectID;
                                 self.propertyUploadVC.imageList = self.propertyDetails.propertyImages;
                                 NSLog(@"Index %ld",(long)self.nIndex);
                                 self.propertyUploadVC.nIndex=self.nIndex;

                                 self.propertyUploadVC.propertyDetails = self.propertyDetails;
                                 [self.navigationController pushViewController:self.propertyUploadVC animated:YES];
                    }
            
            }];
            [request setFailedBlock:^(NSError *error)
            {
                    [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                    [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
            }];

        }else
        {
            [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request addProperty:self.propertyDetailsDict];
            [request setCompletionBlock:^(id results)
             {
                 [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                 NSDictionary *dict=(NSDictionary *) results;
                 
                 if ([dict[@"flag"] boolValue]==1)
                 {
                     self.propertyUploadVC=[GlobalInstance loadStoryBoardId:sPropertyUploadVC];
                     self.propertyUploadVC.propertyObjID=dict[@"propertyObjID"];
                     self.propertyUploadVC.imageList = self.propertyDetails.propertyImages;
                     self.propertyUploadVC.propertyDetails = self.propertyDetails;
                     [self.navigationController pushViewController:self.propertyUploadVC animated:YES];
                     
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

-(BOOL) checkTextField
{
    if (//self.unitTxtField.text.length!=0 &&
        self.houseNumTxtField.text.length!=0 &&
        //self.bldgTxtField.text.length!=0 &&
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
