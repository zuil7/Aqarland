//
//  MKMapView+ZoomLevel.h
//  TestMapView
//
//  Created by Ei Wai on 22/7/12.
//  Copyright (c) 2012 Ei Wai All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end 