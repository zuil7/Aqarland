//
//  MapAnnotation.m
//
//
//
//  
//

#import "MapAnnotation.h"


@implementation MapAnnotation

@synthesize coordinate; 
@synthesize mTitle; 
@synthesize mSubTitle;
@synthesize annType;
@synthesize annIndex;
@synthesize data;
@synthesize mPinIcon;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c 
                  title:(NSString *) t
               subTitle:(NSString *) st {
    
    coordinate = c; 
    self.mTitle = t; 
    self.mSubTitle = st; 
    
    return self;
}

- (NSString *)title {
    
    return mTitle;
}

- (NSString *)subtitle {
    
    return mSubTitle;
}

- (NSString *)pinIcon {
    
    return mPinIcon;
}

@end
