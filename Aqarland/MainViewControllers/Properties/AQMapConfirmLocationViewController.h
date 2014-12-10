//
//  AQMapConfirmLocationViewController.h
//  Aqarland
//
//  Created by Louise on 27/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class PropertyList;

@interface AQMapConfirmLocationViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic,strong) NSMutableDictionary *dictionaryAddress;
@property(nonatomic,strong) UIImage *propertyImg;
@property(nonatomic,strong) NSString *strPropertyID;
@property(nonatomic, strong) PropertyList *propertyDetails;

@property (weak, nonatomic) IBOutlet UIView *pinView;
@property (weak, nonatomic) IBOutlet UIImageView *propertyPic;
@property (weak, nonatomic) IBOutlet UITextField *streetTxtField;
@property (weak, nonatomic) IBOutlet UITextField *cityTxtField;
@property (weak, nonatomic) IBOutlet UITextField *postCodeTxtField;

@end
