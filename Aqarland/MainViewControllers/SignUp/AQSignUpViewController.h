//
//  AQSignUpViewController.h
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import "MapAnnotation.h"
#import "CustomPinView.h"

@interface AQSignUpViewController : UIViewController<UITextFieldDelegate, MKMapViewDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITextField *streetTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *countryTxtFld;

@property (weak, nonatomic) IBOutlet UITextField *cityTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTxtFld;
@property (weak, nonatomic) IBOutlet UIImageView *centerImageTarget;


@end
