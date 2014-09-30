//
//  AQSignUpViewController.m
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQSignUpViewController.h"
#import "IQKeyboardManager.h"
#import "AQCreateAccountViewController.h"

@interface AQSignUpViewController ()
{
    int ZOOM_LEVEL;
    BOOL isCallout;
    CustomPinView *selectedPin;
    NSString *latLongVal;
}
@property (strong, nonatomic) CLLocation *selectedLocation;
@property (strong, nonatomic) NSMutableDictionary *AddressDict;

@property(strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) CLGeocoder *geoCoder;
@property(strong,nonatomic) CLPlacemark *placeMark;

@property(strong,nonatomic) AQCreateAccountViewController *createAcctVC;
@end

@implementation AQSignUpViewController

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tap];
    
    [self.centerImageTarget setHidden:YES];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    //[self setupMapView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.locationManager = [[CLLocationManager alloc] init];
    self.geoCoder = [[CLGeocoder alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic
-(void) customizeHeaderBar
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"Add Location"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIImage *backButtonImage = [UIImage imageNamed:iBackArrowImg];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0,0,22,32);
        [backBtn setImage:backButtonImage forState:UIControlStateNormal];

        [backBtn addTarget:self.viewDeckController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
       /* self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"left", nil) style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(popViewControllerAnimated:)];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];*/
    }

}
-(void) setupMapView
{
    self.AddressDict = [[NSMutableDictionary alloc] init];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 40.740848;
    zoomLocation.longitude= -73.991134;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1609.344,1609.344);
    [self.mapView setRegion:viewRegion animated:YES];
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (void)delayedReverseGeocodeLocation {

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self reverseGeoCode];
    
}

-(BOOL) checkTextField
{
    if (self.streetTxtFld.text.length!=0 &&
        self.countryTxtFld.text.length!=0 &&
        self.cityTxtFld.text.length!=0 &&
        self.postalCodeTxtFld.text.length!=0 ) {
        return 1;
    }else
    {
        return 0;
    }
    
}

#pragma mark - Action
-(IBAction)confirmAddress_touchedup_inside:(id)sender
{
    if([self checkTextField])
    {
        self.AddressDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                          self.streetTxtFld.text,@"street",
                          self.countryTxtFld.text,@"country",
                          self.cityTxtFld.text,@"city",
                          self.postalCodeTxtFld.text,@"postcode",
                          latLongVal,@"latlong",
                          nil];
        NSLog(@"self.AddressDict %@",self.AddressDict);
        self.createAcctVC=[GlobalInstance loadStoryBoardId:sCreateAccountVC];
        self.createAcctVC.placeDict=self.AddressDict;
        [self.navigationController pushViewController:self.createAcctVC animated:YES];
        
    }else
    {
        [GlobalInstance showAlert:iInformation message:@"Please fill out all the textfield to proceed"];
    }
    
}
-(IBAction)mapviewType:(id)sender
{
    if([sender isSelected])
    {
        self.mapView.mapType=MKMapTypeStandard;
        [sender setSelected:NO];
    }else
    {
        self.mapView.mapType=MKMapTypeHybrid;
        [sender setSelected:YES];
    }
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

-(void ) reverseGeoCode
{
    [self.geoCoder reverseGeocodeLocation:self.selectedLocation completionHandler:^(NSArray *placemarks, NSError *error)
    {
        NSLog(@"placemarks %@",placemarks);
       
        if ([placemarks count]!=0)
        {
            NSDictionary *dictionary = [[placemarks objectAtIndex:0] addressDictionary];
            NSLog(@"self.placeMark: %@", dictionary);
            [self.streetTxtFld setText:dictionary[@"Street"]];
            [self.countryTxtFld setText:dictionary[@"Country"]];
            [self.cityTxtFld setText:dictionary[@"City"]];
            [self.postalCodeTxtFld setText:dictionary[@"ZIP"]];
            CLPlacemark *mark=[placemarks objectAtIndex:0];
            float latVal=mark.location.coordinate.latitude;
            float longVal=mark.location.coordinate.longitude;
            NSLog(@"long %f",longVal);
            latLongVal=[NSString stringWithFormat:@"%f,%f",latVal,longVal];
            NSLog(@"latLongVal %@",latLongVal);

            [self showTargetImage];
            //[self showPin:dictionary];
            
        } else
        {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}
-(void) showTargetImage
{
    [self.centerImageTarget setHidden:NO];
}
-(void) showPin:(NSDictionary *) dict
{
    ZOOM_LEVEL= 13.0;
    CLLocationCoordinate2D coordinates = self.locationManager.location.coordinate;
//    MKCoordinateRegion extentsRegion = MKCoordinateRegionMakeWithDistance(coordinates, 800, 800);
//    
//    [self.mapView setRegion:extentsRegion animated:YES];
    
    [self.mapView setCenterCoordinate:coordinates zoomLevel:ZOOM_LEVEL animated:NO];
    
    MapAnnotation *curAnnotation = [[MapAnnotation alloc] initWithCoordinate:coordinates title:dict[@"Street"] subTitle:dict[@"City"]];
    [self.mapView addAnnotation:curAnnotation];
    //[self.mapView selectAnnotation:curAnnotation animated:YES];
}

#pragma mark - MapView
-(void)mapView:(MKMapView *)mv regionWillChangeAnimated:(BOOL)animated
{
    self.selectedLocation =
    [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude
                               longitude:self.mapView.centerCoordinate.longitude];
    [self performSelector:@selector(delayedReverseGeocodeLocation)
               withObject:nil
               afterDelay:0.3];
//    if (isCallout)
//    {
//        [callout removeFromSuperview];
//        CustomPinView *pinview = selectedPin;
//        pinview.image = [UIImage imageNamed:@"dashboard_map_icn_station.png"];
//        isCallout = NO;
//    }
    
    /*
     //---print out the region span - aka zoom level---
     MKCoordinateRegion region = self.mapView.region;
     NSLog(@"latitude delta:%f", region.span.latitudeDelta);
     NSLog(@"longitude delta:%f", region.span.longitudeDelta);
     double centerLatitude= self.mapView.centerCoordinate.latitude;
     double centerLongitude= self.mapView.centerCoordinate.longitude;
     NSLog(@"latitude delta:%f", centerLatitude);
     NSLog(@"longitude delta:%f", centerLongitude);
     MKZoomScale currentZoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
     NSLog(@"current zoom scale is %f",currentZoomScale);
     */
    
    
    
//    if(callout.superview) {
//        //[callout removeFromSuperviewAnimated:YES];
//        [callout removeFromSuperview];
//        //[self populateMap];
//    }
    
}


- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    
    
    CGRect visibleRect = [self.mapView annotationVisibleRect];
    
    for(MKAnnotationView *view in views)
    {
        if([view isKindOfClass:[MapAnnotation class]])
        {
            CGRect endFrame = view.frame;
            
            CGRect startFrame = endFrame;
            
            startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
            view.frame = startFrame;
            
            
            [UIView beginAnimations:@"drop" context:NULL];
            [UIView setAnimationDuration:2];
            
            
            view.frame = endFrame;
            [UIView commitAnimations];
        }
    }
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mpView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *defaultPinID = @"ReusedPin";
    
    CustomPinView *pinView = nil;
    pinView = (CustomPinView *)[mpView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    
    if(! pinView)
    {
        pinView = [[CustomPinView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] ;
    }
    
    //=== PinView customization
    UIImage *customImg = nil;
    CGRect customImgViewRect;
    
    customImg = [UIImage imageNamed:@"dashboard_map_icn_station.png"];
    
    customImgViewRect = CGRectMake(-18, -54, customImg.size.width, customImg.size.height);
    UIImageView *customImgView = [[UIImageView alloc] initWithImage:customImg];
    [customImgView setBackgroundColor:[UIColor redColor]];
    customImgView.frame = customImgViewRect;
    customImgView.alpha = 1;
    
    //set the pinView
    pinView.image = customImg;
    pinView.canShowCallout = YES;
    return pinView;
}

- (void)mapView:(MKMapView *)amapView didSelectAnnotationView:(MKAnnotationView *)aview {
    NSLog(@"aview.tag %ld",(long)aview.tag);
    if(isCallout) {
        
        CustomPinView *pinview = selectedPin;
        pinview.image = [UIImage imageNamed:@"dashboard_map_icn_station.png"];
    }
    selectedPin =(CustomPinView*)aview;
    
    MapAnnotation *annotation = (MapAnnotation*) aview.annotation;
    // new
    CGPoint annoPoint = [self.mapView convertCoordinate:annotation.coordinate toPointToView:amapView];
    
    [self.mapView setCenterCoordinate:[self.mapView convertPoint:annoPoint toCoordinateFromView:amapView] animated:YES];
    
    CustomPinView *pinview = (CustomPinView*)aview;
    pinview.image = [UIImage imageNamed:@"dashboard_map_icn_station_selector.png"];
    
    
}
/*
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aview
{
    CustomPinView *pinview = (CustomPinView*)aview;
    pinview.image = [UIImage imageNamed:@"dashboard_map_icn_station.png"];
    
}
 */

@end
