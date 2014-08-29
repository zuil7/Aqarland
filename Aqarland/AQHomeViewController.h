//
//  AQHomeViewController.h
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AQHomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (weak, nonatomic) IBOutlet UITabBarItem *listPropertyBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *addPropertyBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *myChatBarItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end
