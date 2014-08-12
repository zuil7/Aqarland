//
//  AQSideMenuCell.m
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQSideMenuCell.h"

@implementation AQSideMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) bind:(NSArray *) arr Idx:(NSInteger) idx
{
    NSDictionary *tempDict=[arr objectAtIndex:idx];
    [self.iconImg setImage:[UIImage imageNamed:tempDict[@"icon"]]];
    [self.txtLbl setText:tempDict[@"textTitle"]];
    
}

@end
