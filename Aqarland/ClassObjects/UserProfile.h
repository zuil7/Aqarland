//
//  UserProfile.h
//  Aqarland
//
//  Created by Louise on 29/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQUser.h"
@interface UserProfile : NSObject

@property (nonatomic, strong) NSString *m_objectID;
@property (nonatomic, strong) NSString *m_address;
@property (nonatomic, strong) NSString *m_city;
@property (nonatomic, strong) NSString *m_country;
@property (nonatomic, strong) NSString *m_postCode;
@property (nonatomic, strong) NSString *m_fullName;
@property (nonatomic, strong) NSString *m_latLong;
@property (nonatomic, strong) NSString *m_phoneNumber;
@property (nonatomic, strong) AQUser *user;
@property (nonatomic, strong) UIImage *userAvatar;

@end
