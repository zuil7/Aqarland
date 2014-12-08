//
//  AQViewProperty.h
//  Aqarland
//
//  Created by Louise on 2/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "PropertyList.h"
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import "MapAnnotation.h"
#import "CustomPinView.h"

@protocol AQMyPropertyDelegate <NSObject>
@optional
- (void)updateMyPropertyList:(NSInteger )nDx;
- (void)editMyPropertyList:(PropertyList *)propertyList;
@end

@interface AQViewProperty : UIViewController<iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIScrollView *propertySV;

@property (assign, nonatomic) NSInteger nIndex;
@property (strong, nonatomic) PropertyList *propertyDetails;

@property (weak, nonatomic) IBOutlet UILabel *townHouseLbl;
@property (weak, nonatomic) IBOutlet UILabel *priceLbl;
@property (weak, nonatomic) IBOutlet UILabel *bathRoomLbl;
@property (weak, nonatomic) IBOutlet UILabel *bedRoomLbl;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *amenitiesLbl;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLbl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *contactPerson;
@property (assign, nonatomic) BOOL isUserDetails;
@property (weak) id <AQMyPropertyDelegate> delegate;


@end
