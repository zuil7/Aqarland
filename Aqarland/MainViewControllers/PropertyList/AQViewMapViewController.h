//
//  AQViewMapViewController.h
//  Aqarland
//
//  Created by Louise on 23/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import "MapAnnotation.h"
#import "CustomPinView.h"

@interface AQViewMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic,strong) NSMutableArray *propertyListArr;
@property(nonatomic,strong) NSString *strCity;
@end
