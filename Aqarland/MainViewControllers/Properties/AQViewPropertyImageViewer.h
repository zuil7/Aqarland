//
//  AQViewPropertyImageViewer.h
//  Aqarland
//
//  Created by Louise on 14/1/15.
//  Copyright (c) 2015 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQViewPropertyImageViewer : UIViewController

@property(nonatomic,strong) NSMutableArray *ImgArr;
@property(nonatomic,assign) NSInteger idx;
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollection;

@end
