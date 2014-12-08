//
//  AQPropertyUploadPhoto.h
//  Aqarland
//
//  Created by Louise on 19/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PropertyList;
@interface AQPropertyUploadPhoto : UIViewController
@property (strong, nonatomic) PropertyList *propertyDetails;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCV;
@property (strong, nonatomic) NSString *propertyObjID;
@property (nonatomic, strong) NSMutableArray *imageList;


@end
