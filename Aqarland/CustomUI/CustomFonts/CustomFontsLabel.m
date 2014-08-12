//
//  CustomFontsLabel.m
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "CustomFontsLabel.h"

@implementation RobotoMedium

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont fontWithName:@"Roboto-Medium" size:self.font.pointSize];
    }
    return self;
}

@end

@implementation RobotoRegular

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont fontWithName:@"Roboto-Regular" size:self.font.pointSize];
    }
    return self;
}

@end

@implementation RobotoLight

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont fontWithName:@"Roboto-Light" size:self.font.pointSize];
    }
    return self;
}

@end