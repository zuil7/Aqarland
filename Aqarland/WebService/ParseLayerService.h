//
//  ParseLayerService.h
//  Aqarland
//
//  Created by Louise on 1/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"

typedef void(^AQResultBlock)(id results);
typedef void(^AQFailedBlock)(NSError *error);

@interface ParseLayerService : NSObject

+ (ParseLayerService *) sharedInstance;

- (void)setCompletionBlock:(AQResultBlock)aCompletionBlock;
- (void)setFailedBlock:(AQFailedBlock)aFailedBlock;
//- (void)start;
//- (void)cancel;
//- (BOOL)isExecuting;
//- (BOOL)isFinished;

//Method
-(void) signUp:(NSDictionary *) profileInfo;
-(void) createAccount:(NSDictionary *) profileInfo;
-(void) createAccountViaFB:(NSDictionary *) profileInfo;
- (UserProfile *)fetchCurrentUserProfile;

//Twitter
- (void) loginUserWithAccount:(ACAccount *)twitterAccount;
- (void) loginUserWithTwitterEngine;

//Login
- (void) requestLogin:(NSString *)username passWord:(NSString *) pass;

//FetchProperty
-(void) fetchProperty;
-(void) fetchPropertyPerUser;
-(void) fetchPropertyPerCity:(NSString *) cityStr;
//AddProperty
-(void) addProperty:(NSDictionary *) propertyDetails;
-(void) updateProperty:(NSDictionary *) propertyDetails :(NSString *) propertyObjID;

//UploadImages
-(void) uploadImages:(NSMutableArray *) listImages :(NSString *) objID;

//Filtering
-(void) fetchLocationByCity;
@end
