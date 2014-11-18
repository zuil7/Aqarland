//
//  AQViewProperty.m
//  Aqarland
//
//  Created by Louise on 2/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQViewProperty.h"
#import "ReflectionView.h"

@interface AQViewProperty ()<MBProgressHUDDelegate>
{
    int ZOOM_LEVEL;
}
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *imagesArr;
@property (nonatomic, strong) UIButton *favoriteBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@end

@implementation AQViewProperty

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)awakeFromNib
{
    //set up data
    //your carousel should always be driven by an array of
    //data of some kind - don't store data in your item views
    //or the recycling mechanism will destroy your data once
    //your item views move off-screen
//    self.items = [NSMutableArray array];
//    for (int i = 0; i < 2; i++)
//    {
//        [self.items addObject:@(i)];
//    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [self customizeHeaderBar];
    self.carousel.type = iCarouselTypeCoverFlow2;
    
    self.imagesArr=[[NSMutableArray alloc] initWithArray:self.propertyDetails.propertyImages];
    [self.carousel reloadData];
    [self.carousel scrollToItemAtIndex:0 duration:0.0f];
    
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    ParseLayerService *request =[[ParseLayerService alloc] init];
    [request checkifFavorites:self.propertyDetails];
    [request setCompletionBlock:^(id results)
     {
         [self.favoriteBtn setSelected:YES];
         [self.favoriteBtn setImage:[UIImage imageNamed:iFavoriteImgYellow] forState:UIControlStateSelected];
         [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
     }];
    [request setFailedBlock:^(NSError *error)
     {
         [self.favoriteBtn setSelected:NO];
         [self.favoriteBtn setImage:[UIImage imageNamed:iFavoriteImg] forState:UIControlStateNormal];
         [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        // [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
     }];
    
    [self performSelector:@selector(populateMap) withObject:self afterDelay:0.1];
    
    [self fillData];
   
}
- (void)viewDidLayoutSubviews
{
    [self.propertySV setContentSize:CGSizeMake(320, 900)];
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
    [self.navigationItem setTitle:@"Unit Number"];
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
        UIImage *favoriteImage = [UIImage imageNamed:iFavoriteImg];
        self.favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.favoriteBtn.frame = CGRectMake(0,0,22,22);
        [self.favoriteBtn setImage:favoriteImage forState:UIControlStateNormal];
        
        [self.favoriteBtn addTarget:self action:@selector(favorites_touchedup_inside:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        UIImage *shareImage = [UIImage imageNamed:iShareImg];
        self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareBtn.frame = CGRectMake(0,0,22,22);
        [self.shareBtn setImage:shareImage forState:UIControlStateNormal];
        
        [self.shareBtn addTarget:self action:@selector(share_touchedup_inside:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *favoriteButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.favoriteBtn];
        
        UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.shareBtn];
        
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:favoriteButtonItem, shareButtonItem, nil];
        
        
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void)favorites_touchedup_inside:(id) sender
{
    if(![sender isSelected])
    {
      
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];

        hud.delegate = self;
        hud.labelText = @"Adding as Favorites";
        hud.square = NO;
        [hud show:YES];

            ParseLayerService *request =[[ParseLayerService alloc] init];
            [request addFavorites:self.propertyDetails];
            [request setCompletionBlock:^(id results)
             {
                 [self.favoriteBtn setSelected:YES];
                 [self.favoriteBtn setImage:[UIImage imageNamed:iFavoriteImgYellow] forState:UIControlStateSelected];
                 [hud hide:YES];
             }];
            [request setFailedBlock:^(NSError *error)
             {
                 [hud hide:YES];
                 [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
             }];

    }else
    {
        //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];

        hud.delegate = self;
        hud.labelText = @"Removing as Favorites";
        hud.square = NO;
        [hud show:YES];
        
        ParseLayerService *request =[[ParseLayerService alloc] init];
        [request removeFavorites:self.propertyDetails];
        [request setCompletionBlock:^(id results)
         {
             [self.favoriteBtn setSelected:NO];
             [self.favoriteBtn setImage:[UIImage imageNamed:iFavoriteImg] forState:UIControlStateNormal];
              [hud hide:YES];
             NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInteger:self.nIndex],@"idx",
                                        self.propertyDetails,@"propertyObj",nil];
             [[NSNotificationCenter defaultCenter] postNotificationName:nsUpdateFavorites object:dict];
         }];
        [request setFailedBlock:^(NSError *error)
         {
              [hud hide:YES];
             [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
         }];

    }

}

-(void)share_touchedup_inside:(id) sender
{
    
}

-(void) fillData
{
    [self.townHouseLbl setText:[NSString stringWithFormat:@"%@, %@ sqm",self.propertyDetails.m_propertyType,self.propertyDetails.m_propertySize]];
    PFObject *user=(PFObject *)self.propertyDetails.user;
    
    [self.contactPerson setText:[NSString stringWithFormat:@"Contact %@",user[@"name"]]];
    [self.priceLbl setText:[NSString stringWithFormat:@"$ %@",self.propertyDetails.m_price]];
    [self.bathRoomLbl setText:self.propertyDetails.m_numberOfBaths];
    [self.bedRoomLbl setText:self.propertyDetails.m_numberOfBedrooms];
    [self.addressLbl setText:[NSString stringWithFormat:@"%@, %@, %@, %@, %@",
                              self.propertyDetails.m_houseNumber,
                              self.propertyDetails.m_building,
                              self.propertyDetails.m_street,
                              self.propertyDetails.m_city,
                              self.propertyDetails.m_postCode]];
    [self.amenitiesLbl setText:self.propertyDetails.m_amenities];
    [self.descriptionLbl setText:self.propertyDetails.m_description];
    
   
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.imagesArr count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(ReflectionView *)view
{
    
     PFImageView *customImgView = [[PFImageView alloc] init];
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[ReflectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 195.0f, 195.0f)];
      
        customImgView.frame = view.frame;
        [customImgView setBackgroundColor:[UIColor clearColor]];
        NSDictionary *dictImg=[self.imagesArr objectAtIndex:index];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.alpha = 1.0;
        activityIndicator.center = CGPointMake(customImgView.bounds.size.width / 2.0, customImgView.bounds.size.height / 2.0);
        activityIndicator.hidesWhenStopped = NO;
        [customImgView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [view addSubview:customImgView];
        
        [customImgView setFile:dictImg[@"propertyImg"]];
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
        
    }
    else
    {
        
    }
    [view update];
    return view;
   
}

////////////////////////////////////
#pragma mark - MapViewDelegate
////////////////////////////////////

- (void)populateMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSLog(@"[self.aStations count] %@",self.propertyDetails);
    
    // get the annotation
    NSMutableArray *imagesArr=[[NSMutableArray alloc] initWithArray:self.propertyDetails.propertyImages];
    if([imagesArr count]!=0)
    {
        NSDictionary *dImagesDict= [imagesArr objectAtIndex:0];
        NSArray *latlongArr = [self.propertyDetails.m_latLong componentsSeparatedByString: @","];
        NSString *latStr=[latlongArr objectAtIndex:0];
        NSString *longStr=[latlongArr objectAtIndex:1];
        double lat = [latStr doubleValue];
        double lng = [longStr doubleValue];
        
        ZOOM_LEVEL= 13.0;
        CLLocationCoordinate2D centerCoord = { lat, lng };
        [self.mapView setCenterCoordinate:centerCoord zoomLevel:ZOOM_LEVEL animated:NO];
        
        CLLocationCoordinate2D curLocation;
        curLocation.latitude = lat;
        curLocation.longitude = lng;
        
        NSString *infoTitle = @"Title";
        NSString *desc = @"Desc";
        
        MapAnnotation *curAnnotation = [[MapAnnotation alloc] initWithCoordinate:curLocation title:infoTitle subTitle:desc];
        
        curAnnotation.file=dImagesDict[@"propertyImg"];
        [self.mapView addAnnotation:curAnnotation];
        
    }
}
////////////////////////////////////
#pragma mark - MapView
////////////////////////////////////

-(void)mapView:(MKMapView *)mv regionWillChangeAnimated:(BOOL)animated
{
        
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


- (void)mapView:(MKMapView *)amapView didSelectAnnotationView:(MKAnnotationView *)aview
{
    //NSLog(@"aview.tag %d",aview.tag);
    MapAnnotation *annotation = (MapAnnotation*) aview.annotation;
    
    // new
    CGPoint annoPoint = [self.mapView convertCoordinate:annotation.coordinate toPointToView:amapView];
    [self.mapView setCenterCoordinate:[self.mapView convertPoint:annoPoint toCoordinateFromView:amapView] animated:YES];
    
    NSLog(@"Index %d",annotation.annIndex);
   
    
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aview {
    
}


@end
