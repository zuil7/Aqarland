//
//  AQPropertyListCell.m
//  Aqarland
//
//  Created by Louise on 16/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQPropertyListCell.h"

@implementation AQPropertyListCell

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

-(void) bind:(NSDictionary *) dict Idx:(NSInteger) idx :(NSString *) flag
{
//    NSDictionary *tempDict=[arr objectAtIndex:idx];
//    [self.iconImg setImage:[UIImage imageNamed:tempDict[@"icon"]]];
    if ([flag isEqualToString:@"City"])
    {
        [self.placeLbl setText:dict[@"city"]];
    }else
    {
        [self.placeLbl setText:dict[@"street"]];
    }
    
}

-(void) bindWithLocalData:(NSString *) address Idx:(NSInteger) idx;
{
    //    NSDictionary *tempDict=[arr objectAtIndex:idx];
    //    [self.iconImg setImage:[UIImage imageNamed:tempDict[@"icon"]]];
    NSLog(@"address %@",address);
    [self.placeLbl setText:address];
    
    
}

@end
