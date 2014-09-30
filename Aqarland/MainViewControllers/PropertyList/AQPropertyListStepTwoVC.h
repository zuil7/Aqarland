//
//  AQPropertyListStepTwoVC.h
//  Aqarland
//
//  Created by Louise on 16/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQPropertyListStepTwoVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *propertyListTbl;
@property (nonatomic,strong) NSString *StreetStr;
@property(nonatomic,strong) NSMutableArray *propertyListArr;
@property(nonatomic,strong) NSString *strCity;
@end
