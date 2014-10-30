//
//  AQFilterSearchResult.h
//  Aqarland
//
//  Created by Louise on 22/10/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQFilterSearchResult : UIViewController


@property(nonatomic,strong) NSMutableArray *resultArr;
@property (weak, nonatomic) IBOutlet UITableView *resultTbl;

@end
