//
//  AQPropertyListCell.h
//  Aqarland
//
//  Created by Louise on 16/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyList.h"

@interface AQPropertyListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *placeLbl;
-(void) bind:(NSDictionary *) dict Idx:(NSInteger) idx;

@end
