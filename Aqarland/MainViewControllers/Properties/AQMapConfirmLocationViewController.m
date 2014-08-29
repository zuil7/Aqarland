//
//  AQMapConfirmLocationViewController.m
//  Aqarland
//
//  Created by Louise on 27/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQMapConfirmLocationViewController.h"

@interface AQMapConfirmLocationViewController ()
{
    NSString *latLongVal;
}
@property (strong, nonatomic) CLLocation *selectedLocation;
@property (strong, nonatomic) NSMutableDictionary *AddressDict;

@property(strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) CLGeocoder *geoCoder;
@property(strong,nonatomic) CLPlacemark *placeMark;

@end

@implementation AQMapConfirmLocationViewController

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
    // Do any additional setup after loading the view.
    self.AddressDict=[[NSMutableDictionary alloc] init];
    [self.pinView setHidden:YES];
    [self customizeHeaderBar];
    [self requestGeocode];
    self.propertyPic.layer.cornerRadius = self.propertyPic.frame.size.width / 2;

    self.propertyPic.clipsToBounds = YES;
    [self.propertyPic setImage:self.propertyImg];
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
#pragma mark - Action
////////////////////////////////////
-(IBAction)confirmLocation:(id)sender
{
    if([self checkTextField])
    {
        [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
        
        [self.AddressDict setValue:self.streetTxtField.text forKey:@"Street"];
        [self.AddressDict setValue:self.cityTxtField.text forKey:@"City"];
         //Dont Save zip Code for now
        //[self.AddressDict setValue:self.postCodeTxtField.text forKey:@"ZIP"];
        [self.AddressDict setValue:latLongVal forKey:@"latLong"];
        
        NSLog(@"self.AddressDict %@",self.AddressDict);
        
        ParseLayerService *request=[[ParseLayerService alloc] init];
        [request updateProperty:self.AddressDict :self.strPropertyID];
        [request setCompletionBlock:^(id results)
         {
             if ([results boolValue]==1)
             {
                  [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }
         }];
        [request setFailedBlock:^(NSError *error)
         {
            [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
             [GlobalInstance showAlert:iErrorInfo message:[error description]];
         }];
    }else
    {
          [GlobalInstance showAlert:iInformation message:@"Please fill out all the textfield to proceed"];
    }
}
-(IBAction)updateAddress:(id)sender
{
    [self.AddressDict setValue:self.streetTxtField.text forKey:@"Street"];
    [self.AddressDict setValue:self.cityTxtField.text forKey:@"City"];
    [self.AddressDict setValue:self.postCodeTxtField.text forKey:@"ZIP"];
    NSLog(@"AddressDict %@",self.AddressDict);
    [self updateMaps];
}

////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(BOOL) checkTextField
{
    if (self.streetTxtField.text.length!=0 &&
        self.cityTxtField.text.length!=0 ) {
        return 1;
    }else
    {
        return 0;
    }
    
}

- (void)updateMaps {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressDictionary:self.AddressDict completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            //NSLog(@"coordinate %f",coordinate);
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        } else {
            NSLog(@"error");
        }
    }];
    
}

-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Add Property"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIImage *backImage = [UIImage imageNamed:@""];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0,0,22,32);
        [backBtn setImage:backImage forState:UIControlStateNormal];
        
        [backBtn addTarget:self action:@selector(dummyButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
    }
}

-(void) dummyButton:(id)sender
{
    // Do nothing
}
-(void) requestGeocode
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.geoCoder = [[CLGeocoder alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
}

- (void)delayedReverseGeocodeLocation {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self reverseGeoCode];
    
}

-(void ) reverseGeoCode
{
    [self.geoCoder reverseGeocodeLocation:self.selectedLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         NSLog(@"placemarks %@",placemarks);
         
         if ([placemarks count]!=0)
         {
             NSDictionary *dictionary = [[placemarks objectAtIndex:0] addressDictionary];
             NSLog(@"self.placeMark: %@", dictionary);
             [self.streetTxtField setText:dictionary[@"Street"]];
             [self.cityTxtField setText:dictionary[@"City"]];
             [self.postCodeTxtField setText:dictionary[@"ZIP"]];
             
             CLPlacemark *mark=[placemarks objectAtIndex:0];
             float latVal=mark.location.coordinate.latitude;
             float longVal=mark.location.coordinate.longitude;
             NSLog(@"long %f",longVal);
             latLongVal=[NSString stringWithFormat:@"%f,%f",latVal,longVal];
             NSLog(@"latLongVal %@",latLongVal);
             [self showTargetImage];
             
         } else
         {
             NSLog(@"%@", error.debugDescription);
         }
     } ];
}


-(void) showTargetImage
{
    [self.pinView setHidden:NO];
}
#pragma mark - MapView Delegate Methods

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.selectedLocation =
    [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude
                               longitude:mapView.centerCoordinate.longitude];
    [self performSelector:@selector(delayedReverseGeocodeLocation)
               withObject:nil
               afterDelay:0.3];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // NSLog(@"didUpdateToLocation: %@", newLocation);
    // self.selectedLocation = newLocation;
    
    [self.locationManager stopUpdatingLocation];
    
    CLLocationCoordinate2D coordinates = self.locationManager.location.coordinate;
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = coordinates.latitude;
    zoomLocation.longitude= coordinates.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1609.344,1609.344);
    [self.mapView setRegion:viewRegion animated:YES];
    self.selectedLocation=self.locationManager.location;
    [self performSelector:@selector(delayedReverseGeocodeLocation)
               withObject:nil
               afterDelay:0.3];
    
}
@end
