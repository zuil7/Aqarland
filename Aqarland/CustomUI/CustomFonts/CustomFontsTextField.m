//
//  CustomFontsTextField.m
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "CustomFontsTextField.h"

@implementation RobotoMediumTxtField

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        UIFont *font =  [UIFont fontWithName: @"Roboto-Medium" size: self.font.pointSize];
        [self setFont:font];
    }
    return self;
}

@end

@implementation RobotoRegularTxtField

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        UIFont *font =  [UIFont fontWithName: @"Roboto-Regular" size: self.font.pointSize];
        [self setFont:font];
    }
    return self;
}

@end

@implementation RobotoLightTxtField

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        UIFont *font =  [UIFont fontWithName: @"Roboto-Light" size: self.font.pointSize];
        [self setFont:font];
    }
    return self;
}

@end
