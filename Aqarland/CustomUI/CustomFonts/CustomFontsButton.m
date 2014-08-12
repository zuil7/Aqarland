//
//  CustomFontsButton.m
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "CustomFontsButton.h"

@implementation RobotoMediumBtn
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        //set font
        UIFont *customFont = [UIFont fontWithName:@"Roboto-Medium" size:self.titleLabel.font.pointSize];
        self.titleLabel.font = customFont;
    }
    
    return self;
}
@end

@implementation RobotoRegularBtn
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        //set font
        UIFont *customFont = [UIFont fontWithName:@"Roboto-Regular" size:self.titleLabel.font.pointSize];
        self.titleLabel.font = customFont;
    }
    
    return self;
}
@end

@implementation RobotoLightBtn
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        //set font
        UIFont *customFont = [UIFont fontWithName:@"Roboto-Light" size:self.titleLabel.font.pointSize];
        self.titleLabel.font = customFont;
    }
    
    return self;
}
@end
