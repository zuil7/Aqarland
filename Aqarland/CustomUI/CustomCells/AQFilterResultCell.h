//
//  AQFilterResultCell.h
//  Aqarland
//
//  Created by Louise on 22/10/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQFilterResultCell : UITableViewCell

-(void) bindWithLocalData:(NSString *) address Idx:(NSInteger) idx;

@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@end
