//
//  PropertyList.h
//  Aqarland
//
//  Created by Louise on 29/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQUser.h"
#import "PropertyImages.h"
@interface PropertyList : NSObject

@property (nonatomic, strong) NSString *m_objectID;
@property (nonatomic, strong) NSString *m_unit;
@property (nonatomic, strong) NSString *m_houseNumber;
@property (nonatomic, strong) NSString *m_street;
@property (nonatomic, strong) NSString *m_city;
@property (nonatomic, strong) NSString *m_postCode;
@property (nonatomic, strong) NSString *m_propertyType;
@property (nonatomic, strong) NSString *m_numberOfBedrooms;
@property (nonatomic, strong) NSString *m_numberOfBaths;
@property (nonatomic, strong) NSString *m_amenities;
@property (nonatomic, strong) NSString *m_price;
@property (nonatomic, strong) NSString *m_description;
@property (nonatomic, strong) AQUser *user;
@property (nonatomic, strong) NSString *m_building;
@property (nonatomic, strong) NSNumber *m_propertySize;
@property (nonatomic, strong) NSString *m_latLong;
@property (nonatomic, strong) NSMutableArray *propertyImages;

@end
