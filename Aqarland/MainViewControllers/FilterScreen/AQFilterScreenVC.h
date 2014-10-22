//
//  AQFilterScreenVC.h
//  Aqarland
//
//  Created by Louise on 3/10/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AQFilterResultDelegate <NSObject>
@optional
- (void)resetButton;
@end

@interface AQFilterScreenVC : UIViewController

@property (nonatomic,strong) UIImage *imageScreen;
@property (weak, nonatomic) IBOutlet UIImageView *imageBg;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UISlider *pSizeSlider;
@property (weak, nonatomic) IBOutlet UILabel *sliderVal;
@property (weak, nonatomic) IBOutlet UIButton *propertyType;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@property (nonatomic, unsafe_unretained) id<AQFilterResultDelegate> filterDelegate;
@end
