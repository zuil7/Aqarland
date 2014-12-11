//
//  AQViewMapViewController.m
//  Aqarland
//
//  Created by Louise on 23/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQViewMapViewController.h"
#import "PropertyList.h"
#import "AQViewProperty.h"

@interface AQViewMapViewController ()<MBProgressHUDDelegate>
{
    int ZOOM_LEVEL;
}
@property(nonatomic,strong) AQViewProperty *viewProperty;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation AQViewMapViewController

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
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.HUD];
    
    self.HUD.delegate = self;
    self.HUD.labelText = @"Loading Location";
    self.HUD.square = YES;
    [self.HUD show:YES];

    [self customizeHeaderBar];
    [self getLatLongCity];
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
    [self.navigationItem setTitle:@"View In Map"];
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

-(void) getLatLongCity
{
    NSLog(@"self.strCity %@",self.strCity);
    NSString *location = self.strCity;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0)
                     {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         CLLocation *location = topResult.location;
                         CLLocationCoordinate2D coordinate = location.coordinate;
                         NSLog(@"%f, %f",coordinate.latitude, coordinate.longitude);
                         ZOOM_LEVEL= 10.0;
                         [self.mapView setCenterCoordinate:coordinate zoomLevel:ZOOM_LEVEL animated:NO];
                         [self performSelector:@selector(populateMap) withObject:self afterDelay:0.1];
                         [self.HUD hide:YES];
                     }
                 }
     ];
}

////////////////////////////////////
#pragma mark - MapViewDelegate
////////////////////////////////////

- (void)populateMap{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSLog(@"[self.aStations count] %@",self.propertyListArr);
    // get the annotation
    for (int i=0;i< [self.propertyListArr count]; i++)
    {
        PropertyList *property= (PropertyList *)[self.propertyListArr objectAtIndex:i];
        
        NSMutableArray *imagesArr=[[NSMutableArray alloc] initWithArray:property.propertyImages];
        if([imagesArr count]!=0)
        {
            //NSDictionary *dImagesDict= [imagesArr objectAtIndex:0];
            NSArray *latlongArr = [property.m_latLong componentsSeparatedByString: @","];
            NSString *latStr=[latlongArr objectAtIndex:0];
            NSString *longStr=[latlongArr objectAtIndex:1];
            double lat = [latStr doubleValue];
            double lng = [longStr doubleValue];
            
            NSLog(@"lat %f",lat);
            NSLog(@"lng %f",lng);
            
            CLLocationCoordinate2D curLocation;
            curLocation.latitude = lat;
            curLocation.longitude = lng;
            
            NSString *infoTitle = @"Title";
            NSString *desc = @"Desc";
            
            MapAnnotation *curAnnotation = [[MapAnnotation alloc] initWithCoordinate:curLocation title:infoTitle subTitle:desc];
            curAnnotation.annType = i;
            curAnnotation.annIndex = i;
            
            ParseLayerService *request = [[ParseLayerService alloc] init];
            [request propertyImagesForPropertyList:property];
            [request setCompletionBlock:^(id results) {
                NSArray *images = (NSArray *)results;
                PropertyImages *propertyImage = (PropertyImages *)images[0];
                curAnnotation.file=propertyImage.m_propertyImg;
                [self.mapView addAnnotation:curAnnotation];
            }];
            [request setFailedBlock:^(NSError *error) {
                
            }];
        }
    }
    
}


////////////////////////////////////
#pragma mark - MapView
////////////////////////////////////

-(void)mapView:(MKMapView *)mv regionWillChangeAnimated:(BOOL)animated
{
    
    //CustomPinView *pinview = selectedPin;
    //pinview.image = [UIImage imageNamed:@"map_pin.png"];
    
    
    //---print out the region span - aka zoom level---
    /* MKCoordinateRegion region = self.mapView.region;
     NSLog(@"latitude delta:%f", region.span.latitudeDelta);
     NSLog(@"longitude delta:%f", region.span.longitudeDelta);
     double centerLatitude= self.mapView.centerCoordinate.latitude;
     double centerLongitude= self.mapView.centerCoordinate.longitude;
     NSLog(@"latitude delta:%f", centerLatitude);
     NSLog(@"longitude delta:%f", centerLongitude);
     MKZoomScale currentZoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
     NSLog(@"current zoom scale is %f",currentZoomScale);
     */
    
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
    
    MapAnnotation *myMapAnnotation = (MapAnnotation *)annotation;
    
    //=== PinView customization
    
    UIImage *customImg = [UIImage imageNamed:@"map_pin.png"];
    //CGRect customImgViewRect = CGRectMake(0, 0, customImg.size.width, customImg.size.height);
    PFImageView *customImgView = [[PFImageView alloc] init];
    customImgView.frame = CGRectMake(2, 1, 30, 30);
    [customImgView setBackgroundColor:[UIColor clearColor]];
    customImgView.layer.cornerRadius = customImgView.frame.size.width / 2;
    customImgView.clipsToBounds = YES;
    customImgView.alpha = 1;
    NSLog(@"myMapAnnotation.file %@",myMapAnnotation.file);
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(customImgView.bounds.size.width / 2.0, customImgView.bounds.size.height / 2.0);
    activityIndicator.hidesWhenStopped = NO;
    [customImgView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [customImgView setFile:myMapAnnotation.file];
    [customImgView loadInBackground:^(UIImage *image, NSError *error) {
        if (!error)
        {
            [activityIndicator removeFromSuperview];
        }else
        {
            [activityIndicator removeFromSuperview];
            [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
        }
    }];
    pinView.image = customImg;
    pinView.canShowCallout = NO;
    pinView.tag=myMapAnnotation.annIndex;
    
    
    [pinView addSubview:customImgView];
    
    return pinView;
}


- (void)mapView:(MKMapView *)amapView didSelectAnnotationView:(MKAnnotationView *)aview {
    NSLog(@"aview.tag %ld",(long)aview.tag);
    
    //    CustomPinView *pinview = selectedPin;
    //    pinview.image = [UIImage imageNamed:@"map_pin.png"];
    //
    //selectedPin =(CustomPinView*)aview;
    
    
    //CGPoint point = [self.mapView convertPoint:aview.frame.origin fromView:aview.superview];
    MapAnnotation *annotation = (MapAnnotation*) aview.annotation;
    
    // new
    CGPoint annoPoint = [self.mapView convertCoordinate:annotation.coordinate toPointToView:amapView];
    
    
    [self.mapView setCenterCoordinate:[self.mapView convertPoint:annoPoint toCoordinateFromView:amapView] animated:YES];
    
    //    {
    //    CustomPinView *pinview = (CustomPinView*)aview;
    //    pinview.image = [UIImage imageNamed:@"map_pin.png"];
    //    }
    NSLog(@"Index %d",annotation.annIndex);
    self.viewProperty=[GlobalInstance loadStoryBoardId:sViewPropertyVC];
    self.viewProperty.propertyDetails=[self.propertyListArr objectAtIndex:annotation.annIndex];
    [self.navigationController pushViewController:self.viewProperty animated:YES];
    
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aview {
    
}

@end
