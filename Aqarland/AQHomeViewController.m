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
@interface AQHomeViewController ()<AQSearchViewControllerDelegate,MKMapViewDelegate>
{
    int ZOOM_LEVEL;
    CustomPinView *selectedPin;
    
}
@property(nonatomic,strong) AQSearchViewController *addPropertyVC;
@property(nonatomic,strong) AQSearchViewController *searchVC;
@property(nonatomic,strong) AQViewProperty *viewProperty;
@property(nonatomic,strong) AQPropertListViewController *propertyListVC;
@property(nonatomic,strong) NSMutableArray *propertyListArr;
@property(nonatomic,strong) NSMutableArray *annotationArray;
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
     self.propertyListArr=[[NSMutableArray alloc]initWithArray:[GlobalInstance loadPlistfile:@"propertyTypeList" forKey:@"Station"]];
    
    ZOOM_LEVEL= 11.0;
    CLLocationCoordinate2D centerCoord = { 13.754741, 100.512811 };
    [self.mapView setCenterCoordinate:centerCoord zoomLevel:ZOOM_LEVEL animated:NO];
    [self performSelector:@selector(populateMap) withObject:self afterDelay:0.1];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchPropertyList];
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
/*
-(void)tabbarCustomization
{
//    [self.listPropertyBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,RGB(34, 141, 187), NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.listPropertyBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} forState:UIControlStateNormal];
}*/
-(void) fetchPropertyList
{
    ParseLayerService *request=[[ParseLayerService alloc] init];
    [request fetchProperty];
    [request setCompletionBlock:^(id results)
    {
             
    }];
    [request setFailedBlock:^(NSError *error)
     {
         [GlobalInstance showAlert:iErrorInfo message:[error description]];
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
        NSDictionary *storeDic = (NSDictionary *)[self.propertyListArr objectAtIndex:i];
        double lat = [[storeDic objectForKey:@"lat"] doubleValue];
        double lng = [[storeDic objectForKey:@"lon"] doubleValue];
        
        NSString *infoTitle = @"Title";
        NSString *desc = @"Desc";
        
        CLLocationCoordinate2D curLocation;
        curLocation.latitude = lat;
        curLocation.longitude = lng;

        MapAnnotation *curAnnotation = [[MapAnnotation alloc] initWithCoordinate:curLocation title:infoTitle subTitle:desc];
        
        curAnnotation.annType = i;
        curAnnotation.annIndex = i;
        curAnnotation.data = storeDic;
        curAnnotation.mPinIcon=[storeDic objectForKey:@"pinImg"];
        [self.mapView addAnnotation:curAnnotation];
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
    
    UIImageView *customImgView = [[UIImageView alloc] init];
    customImgView.frame = CGRectMake(2, 1, 30, 30);
    [customImgView setBackgroundColor:[UIColor redColor]];
    customImgView.layer.cornerRadius = customImgView.frame.size.width / 2;
    customImgView.clipsToBounds = YES;
    [customImgView setImage:[UIImage imageNamed:@"login_screen_background.png"]];
    customImgView.alpha = 1;
    
    //set the pinView
    pinView.image = customImg;
    pinView.canShowCallout = NO;
    pinView.tag=myMapAnnotation.annIndex;

    
    [pinView addSubview:customImgView];
    
    return pinView;
}


- (void)mapView:(MKMapView *)amapView didSelectAnnotationView:(MKAnnotationView *)aview {
    NSLog(@"aview.tag %d",aview.tag);
    
//    CustomPinView *pinview = selectedPin;
//    pinview.image = [UIImage imageNamed:@"map_pin.png"];
//    
    selectedPin =(CustomPinView*)aview;
    
    
    //CGPoint point = [self.mapView convertPoint:aview.frame.origin fromView:aview.superview];
    MapAnnotation *annotation = (MapAnnotation*) aview.annotation;
    
    // new
    CGPoint annoPoint = [self.mapView convertCoordinate:annotation.coordinate toPointToView:amapView];
 
    
    //   annoPoint.x += 100;
    [self.mapView setCenterCoordinate:[self.mapView convertPoint:annoPoint toCoordinateFromView:amapView] animated:YES];
  
//    {
//    CustomPinView *pinview = (CustomPinView*)aview;
//    pinview.image = [UIImage imageNamed:@"map_pin.png"];
//    }
    
    self.viewProperty=[GlobalInstance loadStoryBoardId:sViewPropertyVC];
    [self.navigationController pushViewController:self.viewProperty animated:YES];

    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aview {
    
}

@end
