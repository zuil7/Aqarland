//
//  AQViewProperty.m
//  Aqarland
//
//  Created by Louise on 2/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQViewProperty.h"
#import "ReflectionView.h"
#import "AQAddPropertyViewController.h"
#import "KxMenu.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>
#import "AQViewPropertyImageViewer.h"

@interface AQViewProperty ()<MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>
{
    int ZOOM_LEVEL;
}

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *imagesArr;
@property (nonatomic, strong) AQAddPropertyViewController *addPropertyViewController;
@property (nonatomic, strong) UIButton *favoriteBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic,strong) NSString *contactNumberText;

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
    self.carousel.type = iCarouselTypeLinear;
    
    [self propertyImagesForPropertyList:self.propertyDetails];
    if(self.isUserDetails)
    {
        
    
    }else
    {
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
    }
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

- (void) propertyImagesForPropertyList:(PropertyList *)propertyList {
    ParseLayerService *request = [[ParseLayerService alloc] init];
    [request propertyImagesForPropertyList:propertyList];
    [request setCompletionBlock:^(id results) {
        NSArray *images = (NSArray *)results;
        self.imagesArr = [images mutableCopy];
        [self.carousel reloadData];
        [self.carousel scrollToItemAtIndex:0 duration:0.0f];
    }];
    [request setFailedBlock:^(NSError *error) {
        [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
    }];
}

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
        
        if(self.isUserDetails)
        {
            UIImage *deleteImage = [UIImage imageNamed:iDeleteImg];
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteBtn.frame = CGRectMake(0,0,22,22);
            [deleteBtn setImage:deleteImage forState:UIControlStateNormal];
            
            [deleteBtn addTarget:self action:@selector(deleteProperty_touchedup_inside:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *deleteBtnItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];

            UIImage *shareImage = [UIImage imageNamed:iShareImg];
            self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.shareBtn.frame = CGRectMake(0,0,22,22);
            [self.shareBtn setImage:shareImage forState:UIControlStateNormal];
            
            [self.shareBtn addTarget:self action:@selector(share_touchedup_inside:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.shareBtn];
            
            self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:deleteBtnItem, shareButtonItem, nil];
            
        }else
        {
            UIImage *favoriteImage = [UIImage imageNamed:iFavoriteImg];
            self.favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.favoriteBtn.frame = CGRectMake(0,0,22,22);
            [self.favoriteBtn setImage:favoriteImage forState:UIControlStateNormal];
            
            [self.favoriteBtn addTarget:self action:@selector(favorites_touchedup_inside:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *favoriteButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.favoriteBtn];
            
            UIImage *shareImage = [UIImage imageNamed:iShareImg];
            self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.shareBtn.frame = CGRectMake(0,0,22,22);
            [self.shareBtn setImage:shareImage forState:UIControlStateNormal];
            
            [self.shareBtn addTarget:self action:@selector(share_touchedup_inside:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.shareBtn];
            
            self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:favoriteButtonItem, shareButtonItem, nil];

        }

    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void)deleteProperty_touchedup_inside:(id) sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation
                                                    message:@"You sure you want to delete this property"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    [alert show];

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
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Share to Facebook"
                     image:nil
                    target:self
                    action:@selector(fbShare:)],
      [KxMenuItem menuItem:@"Send to Email"
                     image:nil
                    target:self
                    action:@selector(sendToEmail:)]
      ];
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:self.shareBtn.frame
                 menuItems:menuItems];
}
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
-(void)fbShare:(id) sender
{
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       UIGraphicsBeginImageContext(CGSizeMake(self.propertySV.frame.size.width,self.propertySV.frame.size.height));
                       CGContextRef context = UIGraphicsGetCurrentContext();
                       [self.propertySV.layer renderInContext:context];
                       UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
                       UIGraphicsEndImageContext();
                       
                       FBPhotoParams *params = [[FBPhotoParams alloc] init];
                       params.photos = @[screenShot];
                       
                       [FBDialogs presentShareDialogWithPhotoParams:params
                                                        clientState:nil
                                                            handler:^(FBAppCall *call, NSDictionary *results, NSError *error)
                        {
                            NSLog(@"results %@",results);
                            NSString *result=results[@"completionGesture"];
                            if ([result isEqualToString:@"post"])
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation message:@"Photo Successfully Posted" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
                                
                                [alert show];
                               
                                
                            } else
                            {
                                if(error)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iErrorInfo message:error.description delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
                                    
                                    [alert show];
                                }
                            }
                        }];

                   });

}

-(void)sendToEmail:(id) sender
{
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       UIGraphicsBeginImageContext(CGSizeMake(self.propertySV.frame.size.width,self.propertySV.frame.size.height));
                       CGContextRef context = UIGraphicsGetCurrentContext();
                       [self.propertySV.layer renderInContext:context];
                       UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
                       UIGraphicsEndImageContext();
                       
                       NSString *emailTitle = @"Check this out";
                       // Email Content
                       NSString *messageBody = @"Check this Property";
                       // To address
                       
                       MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                       if ([MFMailComposeViewController canSendMail])
                       {
                           mc.mailComposeDelegate = self;
                           [mc setSubject:emailTitle];
                           [mc setMessageBody:messageBody isHTML:NO];

                           NSData *imgData= UIImageJPEGRepresentation(screenShot,1.0);
                           NSString *filename = @"propertyImg";
                           NSString *mimeType = @"image/jpeg";;
                      
                           [mc addAttachmentData:imgData mimeType:mimeType fileName:filename];
                           [GlobalInstance.navController presentViewController:mc animated:YES completion:NULL];
                       }
                });
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation
                                                            message:@"Mail Successfully Sent" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
            
            [alert show];
            }
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [GlobalInstance.navController dismissViewControllerAnimated:YES completion:NULL];
}
-(void) fillData
{
    [self.townHouseLbl setText:[NSString stringWithFormat:@"%@, %@ sqm",self.propertyDetails.m_propertyType,self.propertyDetails.m_propertySize]];
    PFObject *user=(PFObject *)self.propertyDetails.user;
    NSLog(@"User %@",user);
    PFRelation *relation = user[@"userProfile"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
     {
         NSDictionary *dict=[results objectAtIndex:0];
         self.contactNumberText=dict[@"phoneNumber"];
         NSString *contactText = [NSString stringWithFormat:@"Contact No.  %@",dict[@"phoneNumber"]];
         [self.contactNumBtn setTitle:contactText forState:UIControlStateNormal];
         
         NSString *contactPersonText = @"Edit Property";
         self.contactPerson.enabled = YES;
         if (!self.isUserDetails) {
             self.contactPerson.enabled = NO;
             contactPersonText = [NSString stringWithFormat:@"Contact %@",user[@"name"]];
         }
         
         [self.contactPerson setTitle:contactPersonText forState:UIControlStateNormal];
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

       
    }];
    
    
   
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.imagesArr count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
     PFImageView *customImgView = [[PFImageView alloc] init];
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 195.0f, 195.0f)];
      
        customImgView.frame = view.frame;
        [customImgView setBackgroundColor:[UIColor clearColor]];
        if (self.imagesArr) {

            if (self.imagesArr[index] != [NSNull null]) {
                
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
        }
    }
    else
    {
        
    }
    //[view update];
    return view;
   
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return self.wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (self.carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
        {
            return value;
        }
    }
}

#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
      NSDictionary *dictImg=[self.imagesArr objectAtIndex:index];
     NSLog(@"self.imagesArr %@",self.imagesArr);
     NSLog(@"property img %@",dictImg[@"propertyImg"]);
    
    NSMutableArray *arrImg=[[NSMutableArray alloc] init];
    
    for (int i=0;i<[self.imagesArr count]; i++)
    {
        NSDictionary *dictImg=[self.imagesArr objectAtIndex:i];
        PFFile *imageFile = dictImg[@"propertyImg"];
        NSData *imageData = [imageFile getData];
        UIImage *image = [UIImage imageWithData:imageData];
        [arrImg addObject:image];

    }
    AQViewPropertyImageViewer *viewProperty=[GlobalInstance loadStoryBoardId:sImageViewer];
    viewProperty.idx=index;
    viewProperty.ImgArr=arrImg;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewProperty];
    [GlobalInstance.navController presentViewController:nc animated:YES completion:nil];

}

////////////////////////////////////
#pragma mark - IBActions
////////////////////////////////////
- (IBAction)call_btn_touch_up_inside:(id)sender
{
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] )
    {
        NSLog(@"self.contactNumberText %@",self.contactNumberText);
        NSString *callStr=[NSString stringWithFormat:@"telprompt://%@",self.contactNumberText];
        NSURL *url = [NSURL URLWithString:callStr];
        [[UIApplication sharedApplication] openURL:url];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation
                                                        message:@"Device cannot call"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
}
- (IBAction)edit_property_btn_touch_up_inside:(id)sender {
    self.addPropertyViewController = [GlobalInstance loadStoryBoardId:sAddPropertyDetailsVC];
    self.addPropertyViewController.propertyDetails = self.propertyDetails;
    self.addPropertyViewController.nIndex=self.nIndex;
    [self.navigationController pushViewController:self.addPropertyViewController animated:YES];

//    if ([self.delegate respondsToSelector:@selector(editMyPropertyList:)]) {
//        [self.delegate editMyPropertyList:self.propertyDetails];
//    }
}


////////////////////////////////////
#pragma mark - MapViewDelegate
////////////////////////////////////

- (void)populateMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSLog(@"[self.aStations count] %@",self.propertyDetails);
    
    ParseLayerService *request = [[ParseLayerService alloc] init];
    [request propertyImagesForPropertyList:self.propertyDetails];
    [request setCompletionBlock:^(id results) {
        NSArray *images = (NSArray *)results;
        for (PFObject *propertyImage in images) {
            if (![propertyImage isEqual:[NSNull null]]) {
                NSArray *latlongArr = [self.propertyDetails.m_latLong componentsSeparatedByString: @","];
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
                curAnnotation.annType = lat;
                curAnnotation.annIndex = lng;
                curAnnotation.file= propertyImage[@"propertyImg"];
                [self.mapView addAnnotation:curAnnotation];
                
                continue;
            }
        }
    }];
    [request setFailedBlock:^(NSError *error) {
        
    }];
//    // get the annotation
//    NSMutableArray *imagesArr=[[NSMutableArray alloc] initWithArray:self.propertyDetails.propertyImages];
//    if([imagesArr count]!=0)
//    {
//        NSDictionary *dImagesDict= [imagesArr objectAtIndex:0];
//        NSArray *latlongArr = [self.propertyDetails.m_latLong componentsSeparatedByString: @","];
//        NSString *latStr=[latlongArr objectAtIndex:0];
//        NSString *longStr=[latlongArr objectAtIndex:1];
//        double lat = [latStr doubleValue];
//        double lng = [longStr doubleValue];
//        
//        ZOOM_LEVEL= 13.0;
//        CLLocationCoordinate2D centerCoord = { lat, lng };
//        [self.mapView setCenterCoordinate:centerCoord zoomLevel:ZOOM_LEVEL animated:NO];
//        
//        CLLocationCoordinate2D curLocation;
//        curLocation.latitude = lat;
//        curLocation.longitude = lng;
//        
//        NSString *infoTitle = @"Title";
//        NSString *desc = @"Desc";
//        
//        MapAnnotation *curAnnotation = [[MapAnnotation alloc] initWithCoordinate:curLocation title:infoTitle subTitle:desc];
//        
//        curAnnotation.file= (imagesArr[0] != [NSNull null]) ? dImagesDict[@"propertyImg"] : nil;
//        [self.mapView addAnnotation:curAnnotation];
//        
//    }
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
////////////////////////////
#pragma mark - UIAlertViewDelegate
///////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        NSLog(@"Cancel");
    }else
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        ParseLayerService *request =[[ParseLayerService alloc] init];
        [request deleteProperty:self.propertyDetails];
        [request setCompletionBlock:^(id results)
         {
           
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
               [self.delegate updateMyPropertyList:self.nIndex];
             [self.navigationController popToRootViewControllerAnimated:YES];
         }];
        [request setFailedBlock:^(NSError *error)
         {
          
             [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
              [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
         }];

    }
}
@end
