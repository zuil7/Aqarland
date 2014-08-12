//
//  AQSideMenuCell.h
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQSideMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *txtLbl;

-(void) bind:(NSArray *) arr Idx:(NSInteger) idx;
@end
