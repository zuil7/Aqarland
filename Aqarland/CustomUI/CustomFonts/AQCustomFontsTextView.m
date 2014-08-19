//
//  AQCustomFontsTextView.m
//  Aqarland
//
//  Created by Louise on 19/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQCustomFontsTextView.h"

@implementation RobotoMediumTxtView

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        UIFont *font =  [UIFont fontWithName: @"Roboto-Medium" size: self.font.pointSize];
        [self setFont:font];
    }
    return self;
}

@end

@implementation RobotoRegularTxtView

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        UIFont *font =  [UIFont fontWithName: @"Roboto-Regular" size: self.font.pointSize];
        [self setFont:font];
    }
    return self;
}

@end

@implementation RobotoLightTxtView

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        UIFont *font =  [UIFont fontWithName: @"Roboto-Light" size: self.font.pointSize];
        [self setFont:font];
    }
    return self;
}

@end
