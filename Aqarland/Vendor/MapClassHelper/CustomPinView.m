//
//  CustomPinView.m
//
//
//
//  
//

#import "CustomPinView.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation CustomPinView

#define kDropCompressAmount 0.1

- (id)initWithAnnotation:(id )annotation reuseIdentifier: (NSString *)defaultPinID
{
    self = [super initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    
    if(self)
    {
        self.image = nil;
    }
    
    return self;
}

- (void)didMoveToSuperview
{
    if (!self.superview) {
        [self.layer removeAllAnimations];
        return;
    }
    
    float xOriginDivider = 20.;
    float pos = 0;
    
    UIView *mySuperview = self.superview;
    while (mySuperview && ![mySuperview isKindOfClass:[MKMapView class]])
        mySuperview = mySuperview.superview;
    if ([mySuperview isKindOfClass:[MKMapView class]]) 
        pos = [((MKMapView *) mySuperview) convertCoordinate:self.annotation.coordinate toPointToView:mySuperview].x / xOriginDivider;
    
    float yOffsetMultiplier = 20.;
    float timeOffsetMultiplier = 0.05;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.4 + timeOffsetMultiplier * pos;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -400 - yOffsetMultiplier * pos, 0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.duration = 0.05;
    animation2.beginTime = animation.duration;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation2.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DMakeTranslation(0, self.layer.frame.size.height*kDropCompressAmount, 0), 1.0, 1.0-kDropCompressAmount, 1.0)];
    animation2.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation3.duration = 0.10;
    animation3.beginTime = animation.duration+animation2.duration;
    animation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation3.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation3.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:animation, animation2, animation3, nil];
    group.duration = animation.duration+animation2.duration;//+animation3.duration;
    group.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:group forKey:nil];    
}

@end