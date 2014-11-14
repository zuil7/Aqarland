//
//  AQHomeViewController.m
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQHomeViewController.h"
#import "AQSearchViewController.h"
#import "AQAddPropertyViewController.h"
#import "AQViewProperty.h"
#import "AQPropertListViewController.h"
#import "PropertyList.h"
#import "AQFilterProperTypeVC.h"
#import "AQFilterScreenVC.h"

@interface AQHomeViewController ()<AQSearchViewControllerDelegate,MKMapViewDelegate,CLLocationManagerDelegate,MBProgressHUDDelegate,AQFilterResultDelegate, AQFilterProperTypeVCDelegate>
{
    int ZOOM_LEVEL;
    CustomPinView *selectedPin;
    
}
@property(nonatomic,strong) AQSearchViewController *addPropertyVC;
@property(nonatomic,strong) AQSearchViewController *searchVC;
@property(nonatomic,strong) AQViewProperty *viewProperty;
@property(nonatomic,strong) AQPropertListViewController *propertyListVC;
@property(nonatomic,strong) AQFilterScreenVC *filterVC;
@property(nonatomic,strong) AQFilterProperTypeVC *filterPropertyTypeVC;
@property(nonatomic,strong) NSMutableArray *propertyListArr;
@property(nonatomic,strong) NSMutableArray *annotationArray;
@property(nonatomic,strong) PropertyList *property;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property(strong,nonatomic) CLLocationManager *locationManager;
@end

@implementation AQHomeViewController

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
    // Do any additional setup after loading the view from its nib.
     [self customizeHeaderBar];
//  self.propertyListArr=[[NSMutableArray alloc]initWithArray:[GlobalInstance loadPlistfile:@"propertyTypeList" forKey:@"Station"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchNewProperty)
                                                 name:nsFetchProperty
                                               object:nil];
    
    [self fetchPropertyList];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self fetchPropertyList];
//    [self.mapView removeAnnotations:self.mapView.annotations];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}


////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(void)fetchNewProperty
{
    [self fetchPropertyList];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

-(void) getCurrentLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}


-(void) displayPinAnnotation:(CLLocationCoordinate2D) coor
{
    //Lower value zoom OUT
    //Higher value zoom IN
    ZOOM_LEVEL= 13.0;
    CLLocationCoordinate2D centerCoord = { coor.latitude, coor.longitude };
    [self.mapView setCenterCoordinate:centerCoord zoomLevel:ZOOM_LEVEL animated:NO];
    [self performSelector:@selector(populateMap) withObject:self afterDelay:0.1];
    [self.HUD hide:YES];
    
}
-(void) fetchPropertyList
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.HUD];
    
    self.HUD.delegate = self;
    self.HUD.labelText = @"Loading Location";
    self.HUD.square = YES;
    [self.HUD show:YES];

    
    
    ParseLayerService *request=[[ParseLayerService alloc] init];
    [request fetchProperty];
    [request setCompletionBlock:^(id results)
    {
        
        self.propertyListArr=[[NSMutableArray alloc] initWithArray:results];
        NSLog(@"self.propertyListArr %lu",(unsigned long)[self.propertyListArr count]);
        [self getCurrentLocation];
        
    }];
    [request setFailedBlock:^(NSError *error)
     {
         [self.HUD hide:YES];
         [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
         [self.HUD hide:YES];
    }];
}
-(void) customizeHeaderBar
{
    //self.navigationItem.titleView = self.searchBar;
    //[self.navigationItem setTitle:@"Property Map"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"left", nil) style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
        UIImage *menuImage = [UIImage imageNamed:iMenuImg];
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0,0,22,32);
        [menuBtn setImage:menuImage forState:UIControlStateNormal];
        
        [menuBtn addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];

    }
    
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)])
    {
        UIImage *searchImage = [UIImage imageNamed:iSearchImg];
        UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        searchBtn.frame = CGRectMake(0,0,22,32);
        [searchBtn setImage:searchImage forState:UIControlStateNormal];
        
        [searchBtn addTarget:self action:@selector(searchBarBtn_touchedupInside:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
        [self.navigationItem setRightBarButtonItem:barButtonItem];
        
    }

}
////////////////////////////////////
#pragma mark - Action
////////////////////////////////////
-(IBAction)filterOption_touchedup_Inside:(id)sender
{
    if(self.filterBtn.tag==[sender tag])
    {
        [self.filterBtn setSelected:YES];
        [self.propertyTypeBtn setSelected:NO];
        
        
        self.filterVC=[GlobalInstance loadStoryBoardId:sPropertyFilterVC];
        [self.filterVC setFilterDelegate:self];
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           UIGraphicsBeginImageContext(CGSizeMake(self.navigationController.view.frame.size.width,self.navigationController.view.frame.size.height));
                           CGContextRef context = UIGraphicsGetCurrentContext();
                           [self.navigationController.view.layer renderInContext:context];
                           UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
                           UIGraphicsEndImageContext();
                           
                           self.filterVC.imageScreen=screenShot;
                           //[self.navigationController addChildViewController:self.filterVC];
                           self.filterVC.view.frame = self.view.bounds;
                           [self.navigationController.view addSubview:self.filterVC.view];
                           //[self.filterVC didMoveToParentViewController:self];
                       });
        
        
        
    }else
    {
        [self.filterBtn setSelected:NO];
        [self.propertyTypeBtn setSelected:YES];
        self.filterPropertyTypeVC=[GlobalInstance loadStoryBoardId:sPropertyFilterTypeVC];
        [self.filterPropertyTypeVC setFilterDelegate:self];
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           UIGraphicsBeginImageContext(CGSizeMake(self.navigationController.view.frame.size.width,self.navigationController.view.frame.size.height));
                           CGContextRef context = UIGraphicsGetCurrentContext();
                           [self.navigationController.view.layer renderInContext:context];
                           UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
                           UIGraphicsEndImageContext();
                           
                           self.filterPropertyTypeVC.imageScreen=screenShot;
                           //[self.navigationController addChildViewController:self.filterPropertyTypeVC];
                           self.filterPropertyTypeVC.view.frame = self.view.frame;
                           [self.navigationController.view addSubview:self.filterPropertyTypeVC.view];
                           //[self.filterPropertyTypeVC didMoveToParentViewController:self];
                       });
    }
    
}
-(IBAction)viewPropertyList:(id)sender
{
    self.viewProperty=[GlobalInstance loadStoryBoardId:sViewPropertyVC];
    [self.navigationController pushViewController:self.viewProperty animated:YES];
}
-(IBAction)listProperty_touchedup_inside:(id)sender
{
   self.propertyListVC = [GlobalInstance loadStoryBoardId:sPropertyListVC];
   [self.navigationController pushViewController:self.propertyListVC animated:YES];
}
-(IBAction)addProperty_touchedup_inside:(id)sender
{
    self.addPropertyVC=[GlobalInstance loadStoryBoardId:sAddPropertyVC];
    [self.navigationController pushViewController:self.addPropertyVC animated:YES];
}
-(IBAction)myChats_touchedup_inside:(id)sender
{
    
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
////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////

-(void) searchBarBtn_touchedupInside:(id) sender
{
    [self.navigationController setNavigationBarHidden:YES];
    self.searchVC = [GlobalInstance loadStoryBoardId:sSearchVC];
    
    [self.searchVC setSearchVCDelegate:self];
    
    [self addChildViewController:self.searchVC];
    self.searchVC.view.frame = self.view.bounds;
    [self.view addSubview:self.searchVC.view];
    [self.searchVC didMoveToParentViewController:self];
   
   

}
////////////////////////////////////
#pragma mark - AQSearchViewControllerDelegate
////////////////////////////////////
- (void)showNavigationBar
{
     [self.navigationController setNavigationBarHidden:NO];
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
            NSDictionary *dImagesDict= [imagesArr objectAtIndex:0];
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
            curAnnotation.file=dImagesDict[@"propertyImg"];
            [self.mapView addAnnotation:curAnnotation];
        }
        
        
    }
    
}

////////////////////////////////////
#pragma mark - MapView
////////////////////////////////////

-(void)mapView:(MKMapView *)mv regionWillChangeAnimated:(BOOL)animated
{
    
    CustomPinView *pinview = selectedPin;
    pinview.image = [UIImage imageNamed:@"map_pin.png"];
    
    
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
    selectedPin =(CustomPinView*)aview;
    
    
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


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [self.HUD hide:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    CLLocationCoordinate2D coordinates = self.locationManager.location.coordinate;
//    CLLocationCoordinate2D zoomLocation;
//    zoomLocation.latitude = coordinates.latitude;
//    zoomLocation.longitude= coordinates.longitude;
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1609.344,1609.344);
//    [self.mapView setRegion:viewRegion animated:YES];
    [self displayPinAnnotation:coordinates];
    
}

- (void)resetButton
{
    [self.filterBtn setSelected:NO];
}

- (void)filterPropertyTypeVCDidEndPresenting
{
    [self.propertyTypeBtn setSelected:NO];
}
@end
