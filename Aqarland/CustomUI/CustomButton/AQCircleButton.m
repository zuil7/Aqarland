//
//  AQCircleButton.m
//  Aqarland
//
//  Created by Enrico Paulo Lazarte on 9/24/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQCircleButton.h"

@interface AQCircleButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) UIColor *color;
@end

@implementation AQCircleButton

- (void)drawCircleButton:(UIColor *)color {
    self.color = color;
    [self setTitleColor:color forState:UIControlStateNormal];
    self.circleLayer = [CAShapeLayer layer];
    [self.circleLayer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width,
                                           [self bounds].size.height)];
    [self.circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    //UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    float startAngle = 2 * M_PI * 0.0 - M_PI_2;
    float endAngle = 2 * M_PI * 1.0 - M_PI_2;
    float radius = 40.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame)/2 + 1.0f,CGRectGetWidth(self.frame)/2 - 5.0f)
                                                 radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    [self.circleLayer setPath:[path CGPath]];
    [self.circleLayer setStrokeColor:[color CGColor]];
    [self.circleLayer setLineWidth:2.0f];
    [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    [[self layer] addSublayer:self.circleLayer];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.circleLayer setFillColor:[UIColor colorWithRed:0.49f green:0.75f blue:0.93f alpha:1.0f].CGColor];
    } else {
        [self.circleLayer setFillColor:[UIColor clearColor].CGColor];
        self.titleLabel.textColor = self.color;
    }
}

@end
