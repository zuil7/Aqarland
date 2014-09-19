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

@interface AQViewProperty : UIViewController<iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIScrollView *propertySV;

@property (assign, nonatomic) NSInteger nIndex;
@property (strong, nonatomic) PropertyList *propertyDetails;
@end
