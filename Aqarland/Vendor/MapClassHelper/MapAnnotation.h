//
//  MapAnnotation.h
//
//
//
// 
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapAnnotation : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D coordinate; 
    NSString *mTitle; 
    NSString *mSubTitle;
    NSString *mPinIcon;
    int annType;
    int annIndex;
    
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; 
@property (nonatomic, retain) NSString *mTitle; 
@property (nonatomic, retain) NSString *mSubTitle;
@property (nonatomic, retain) NSString *mPinIcon;
@property (nonatomic, retain) NSString *mSelectedIcon;
@property (nonatomic, assign) int annType;
@property (nonatomic, assign) int annIndex;
@property ( unsafe_unretained) NSDictionary *data;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c 
                  title:(NSString *) t
               subTitle:(NSString *) st;
-(NSString *)title;
-(NSString *)subtitle;

@end
