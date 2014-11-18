//
//  AQShortListViewController.h
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQShortListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *favoriteTbl;
@property(nonatomic,strong) NSMutableArray *propertyListArr;

@end
