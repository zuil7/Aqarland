//
//  AQSearchViewController.h
//  Aqarland
//
//  Created by Louise on 13/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AQSearchViewControllerDelegate <NSObject>

@optional
- (void)showNavigationBar;

@end
@interface AQSearchViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchTbl;
@property (nonatomic, unsafe_unretained) id<AQSearchViewControllerDelegate> searchVCDelegate;

@end
