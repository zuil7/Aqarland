//
//  AQPropertyDetailsViewController.m
//  Aqarland
//
//  Created by Louise on 15/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQPropertyDetailsViewController.h"
#import "RMPickerViewController.h"
#import "AQPropertyUploadPhoto.h"
#import "AQAddPropertyViewController.h"
@interface AQPropertyDetailsViewController ()<RMPickerViewControllerDelegate>

@property(nonatomic,strong) NSArray *propertyList;
@property(nonatomic,strong) AQAddPropertyViewController *addPropertyVC;
@property(nonatomic,assign) int buttonTag;
@property(nonatomic,strong) NSArray *typeOfProperty;

@end

@implementation AQPropertyDetailsViewController

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
    self.propertyAddress=[[NSMutableDictionary alloc] init ];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    self.typeOfProperty=[NSArray arrayWithObjects:@"For Rent",@"For Sale", nil];
    self.propertyList=[GlobalInstance loadPlistfile:@"propertyTypeList" forKey:@"propertyList"];
    // Do any additional setup after loading the view.
    [self customizeHeaderBar];
    NSLog(@"propertyAddress %@",self.propertyAddress);
}

- (void)viewDidLayoutSubviews
{
    [self.containerScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 560)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.propertyDetails) {
        self.propertyTypeLbl.text = self.propertyDetails.m_propertyType;
        self.areaTxtField.text = [NSString stringWithFormat:@"%@",self.propertyDetails.m_propertySize];
        self.nBedroomsTxtField.text = self.propertyDetails.m_numberOfBedrooms;
        self.nBathsTxtField.text = self.propertyDetails.m_numberOfBaths;
        self.amenitiesTxtField.text = self.propertyDetails.m_amenities;
        self.descTxtView.text = self.propertyDetails.m_description;
        if ([self.propertyDetails.m_ofType isEqualToString:@"Sale"])
        {
            self.typeOfProp.text =@"For Sale";
        }else
        {
            self.typeOfProp.text=@"For Rent";
        }
        self.priceLbl.text = self.propertyDetails.m_price;

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
#pragma mark - Logic
////////////////////////////////////
-(BOOL) checkTextField
{
    if (![self.propertyTypeLbl.text isEqualToString:@"Property Type"] &&
        self.areaTxtField.text.length!=0 &&
        self.nBedroomsTxtField.text.length!=0 &&
        self.nBathsTxtField.text.length!=0 &&
        self.amenitiesTxtField.text.length!=0 &&
        self.typeOfProp.text.length!=0 &&
        self.priceLbl.text.length!=0 &&
        self.descTxtView.text.length!=0 ) {
        return 1;
    }else
    {
        return 0;
    }
    
}

-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Property Details"];
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
        
        [forwardBtn addTarget:self action:@selector(goToAddPropertyView:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];
        [self.navigationItem setRightBarButtonItem:barButtonItem];
        
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

////////////////////////////////////
#pragma mark - Action
////////////////////////////////////
-(IBAction) popertyType_touchedup_inside:(id) sender
{
    self.buttonTag=(int)[sender tag];
    RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    pickerVC.delegate = self;
    
    //You can enable or disable bouncing and motion effects
    //pickerVC.disableBouncingWhenShowing = YES;
    //pickerVC.disableMotionEffects = YES;
    
    [pickerVC show];
}




-(void) goToAddPropertyView:(id) sender
{
    if([self checkTextField])
    {
        [self.propertyAddress setValue:self.propertyTypeLbl.text forKey:@"propertyType"];
        [self.propertyAddress setValue:self.areaTxtField.text forKey:@"nPropertySize"];
        [self.propertyAddress setValue:self.nBedroomsTxtField.text forKey:@"numberOfBedrooms"];
        [self.propertyAddress setValue:self.nBathsTxtField.text forKey:@"numberOfBaths"];
        [self.propertyAddress setValue:self.amenitiesTxtField.text forKey:@"amenities"];
        [self.propertyAddress setValue:self.typeOfProp.text forKey:@"ofType"];
        [self.propertyAddress setValue:self.priceLbl.text forKey:@"price"];
        [self.propertyAddress setValue:self.descTxtView.text forKey:@"description"];
        NSLog(@"self.propertyAddress %@",self.propertyAddress);
        if (self.propertyDetails)
        {
            [self.propertyAddress setValue:self.propertyDetails.m_objectID forKey:@"objectId"];
        }
        
        if (self.propertyDetails)
        {
             self.addPropertyVC=[GlobalInstance loadStoryBoardId:sAddPropertyVC];
             self.addPropertyVC.propertyDetailsDict=self.propertyAddress;
             self.addPropertyVC.propertyDetails=self.propertyDetails;
            NSLog(@"Index %ld",(long)self.nIndex);

            self.addPropertyVC.nIndex=self.nIndex;

             [self.navigationController pushViewController:self.addPropertyVC animated:YES];

//            [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
//            ParseLayerService *request=[[ParseLayerService alloc] init];
//            [request updatePropertyList:self.propertyDetails withDetails:self.propertyAddress];
//            [request setCompletionBlock:^(id success)
//             {
//                 [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
//                
//                 if ([success boolValue]) {
//                     self.propertyUploadVC=[GlobalInstance loadStoryBoardId:sAddPropertyVC];
//                     self.propertyUploadVC.propertyObjID=self.propertyDetails.m_objectID;
//                     self.propertyUploadVC.imageList = self.propertyDetails.propertyImages;
//                     self.propertyUploadVC.propertyDetails = self.propertyDetails;
//                     [self.navigationController pushViewController:self.propertyUploadVC animated:YES];
//                 }
//                 
//             }];
//            [request setFailedBlock:^(NSError *error)
//             {
//                 [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
//                 [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
//             }];
        
        }
        else
        {
            self.addPropertyVC=[GlobalInstance loadStoryBoardId:sAddPropertyVC];
            NSLog(@"self.propertyAddress %@",self.propertyAddress);
            self.addPropertyVC.propertyDetailsDict=self.propertyAddress;
//            self.propertyUploadVC.propertyObjID=dict[@"propertyObjID"];
//            self.propertyUploadVC.imageList = self.propertyDetails.propertyImages;
//            self.propertyUploadVC.propertyDetails = self.propertyDetails;
            [self.navigationController pushViewController:self.addPropertyVC animated:YES];
            /*
            [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
            ParseLayerService *request=[[ParseLayerService alloc] init];
            [request addProperty:self.propertyAddress];
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
             */
        }
    }else
    {
        [GlobalInstance showAlert:iInformation message:@"Please fill out all the textfield to proceed"];

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
    if (self.buttonTag==0)
    {
        
        NSString *selectedStr=[self.propertyList objectAtIndex:idx];
        [self.propertyTypeLbl setText:selectedStr];

    }else
    {
        NSString *selectedStr=[self.typeOfProperty objectAtIndex:idx];
        [self.typeOfProp setText:selectedStr];

        
    }
}

- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc {
    NSLog(@"Selection was canceled");
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.buttonTag==0)
    {
        return [self.propertyList count];

    }else
    {
        return [self.typeOfProperty count];
    }
   
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str;
    if (self.buttonTag==0)
    {
        str=[self.propertyList objectAtIndex:row];
    }else
    {
        str=[self.typeOfProperty objectAtIndex:row];

    }
    return str;
}


@end
