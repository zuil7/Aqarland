//
//  AQFilterResultCell.m
//  Aqarland
//
//  Created by Louise on 22/10/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQFilterResultCell.h"

@implementation AQFilterResultCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) bindWithLocalData:(NSString *) address Idx:(NSInteger) idx
{
    [self.addressLbl setText:address];
}
@end
