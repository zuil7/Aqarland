//
//  AQFilterScreenVC.m
//  Aqarland
//
//  Created by Louise on 3/10/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQFilterScreenVC.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>
#import "RMPickerViewController.h"

#define blurValue 6.0
#define r0 @"0"
#define r1 @"1"
#define r2 @"2"
#define r3 @"3"

@interface AQFilterScreenVC ()<RMPickerViewControllerDelegate>
{
    BOOL isLocation;
}
@property (nonatomic, weak) IBOutlet FXBlurView *blurView;
@property(nonatomic,strong) NSArray *locationList;
@property(nonatomic,strong) NSArray *propertyList;
@end

@implementation AQFilterScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.imageBg setImage:self.imageScreen];
    self.blurView.dynamic=NO;
    self.blurView.blurRadius=blurValue;
    
    self.propertyList=[GlobalInstance loadPlistfile:@"propertyTypeList" forKey:@"propertyList"];

    
    [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
    ParseLayerService *request=[[ParseLayerService alloc] init];
    [request fetchLocationByCity];
    [request setCompletionBlock:^(id results)
     {
         [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
         self.locationList=[NSArray arrayWithArray:results];
     }];
    [request setFailedBlock:^(NSError *error)
     {
          [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
         [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////
#pragma - Touched
////////////////////////
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    if(!CGRectContainsPoint(self.filterView.frame, touchPoint))
    {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }

}

////////////////////////////////////
#pragma mark - Action
////////////////////////////////////
-(IBAction) location_touchedup_inside:(id) sender
{
    RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    pickerVC.delegate = self;
    
    isLocation=YES;
    //You can enable or disable bouncing and motion effects
    //pickerVC.disableBouncingWhenShowing = YES;
    //pickerVC.disableMotionEffects = YES;
    
    [pickerVC show];
}

-(IBAction) propertyType_touchedup_inside:(id) sender
{
    RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    pickerVC.delegate = self;
    
    isLocation=NO;
    //You can enable or disable bouncing and motion effects
    //pickerVC.disableBouncingWhenShowing = YES;
    //pickerVC.disableMotionEffects = YES;
    
    [pickerVC show];
}

-(IBAction) slider_changedValue:(UISlider *) sender
{
    [self.sliderVal setText:[NSString stringWithFormat:@"%.0f sqm",sender.value]];
}

-(IBAction)clearFields:(id)sender
{
    [self.locationBtn setTitle:@"Location" forState:UIControlStateNormal];
    [self.propertyType setTitle:@"Property Type" forState:UIControlStateNormal];
    [self.pSizeSlider setValue:0.0];
    [self.sliderVal setText:@"0 sqm"];
    
}

-(IBAction)searchFilter_touchedup_inside:(id)sender
{
    if([[self checkTextField] isEqualToString:r1])
    {
         [GlobalInstance showAlert:iInformation message:@"Please complete the textfield"];
    }else if([[self checkTextField] isEqualToString:r3])
    {
         [GlobalInstance showAlert:iInformation message:@"Sqm cannot be Zero"];
    }else
    {
        [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
        
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        dict[@"city"] = self.locationBtn.titleLabel.text;
        dict[@"pType"] = self.propertyType.titleLabel.text;
        dict[@"pSize"] = [NSString stringWithFormat:@"%.2f",self.pSizeSlider.value];
        NSLog(@"dict %@",dict);
        ParseLayerService *request=[[ParseLayerService alloc] init];
        [request FilterSearch:dict];
        [request setCompletionBlock:^(id results)
         {
             [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
         }];
        [request setFailedBlock:^(NSError *error)
         {
              [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
             [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
         }];

    }
  
    
}
////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(NSString *) checkTextField
{
    
    
//    if (self.locationBtn.titleLabel.text.length!=0 &&
//        self.propertyType.titleLabel.text.length!=0 &&
//        self.pSizeSlider.value !=0) {
//        return 1;
//    }else
//    {
//        return 0;
//    }
    
    if (![self.locationBtn.titleLabel.text isEqualToString:@"Location"] &&
        ![self.propertyType.titleLabel.text isEqualToString:@"Property Type"])
    {
         if(self.pSizeSlider.value !=0)
         {
             return r0;
         }else
         {
             return r3;
         }
        
    }else
    {
        return r1;
    }
    return r0;
}
////////////////////////
#pragma mark - RMPickerViewController Delegates
////////////////////////
- (void)pickerViewController:(RMPickerViewController *)vc didSelectRows:(NSArray *)selectedRows
{
    if (isLocation)
    {
        int idx=[[selectedRows objectAtIndex:0] intValue];
        NSString *selectedStr=[self.locationList objectAtIndex:idx];
        [self.locationBtn setTitle:selectedStr forState:UIControlStateNormal];
    }else
    {
        int idx=[[selectedRows objectAtIndex:0] intValue];
        NSString *selectedStr=[self.propertyList objectAtIndex:idx];
        [self.propertyType setTitle:selectedStr forState:UIControlStateNormal];
    }
 
}

- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc {
    NSLog(@"Selection was canceled");
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (isLocation)
    {
    return [self.locationList count];
    }
    else
    {
    return [self.propertyList count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (isLocation)
    {
        NSString *str=[self.locationList objectAtIndex:row];
        return str;
    }else
    {
        NSString *str=[self.propertyList objectAtIndex:row];
        return str;

    }
}
@end
