//
//  AQUser.h
//  Aqarland
//
//  Created by Louise on 29/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AQUser : NSObject


@property (nonatomic, strong) NSString *m_objectID;
@property (nonatomic, strong) NSString *m_userName;
@property (nonatomic, strong) NSString *m_email;
@property (nonatomic, assign) BOOL *m_emailVerified;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *m_name;
@property (nonatomic, strong) NSString *m_loginType;
@end
