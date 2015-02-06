//
//  ParseLayerService.h
//  Aqarland
//
//  Created by Louise on 1/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"
#import "PropertyList.h"

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
-(void) fetchCurrentUserProfile;
//- (void) updateUserProfile:(UserProfile *)userProfile pfUser:(PFUser *)pfUser;
//Twitter
- (void) loginUserWithAccount:(ACAccount *)twitterAccount;
- (void) loginUserWithTwitterEngine;

//Login
- (void) requestLogin:(NSString *)username passWord:(NSString *) pass;

//FetchProperty
-(void) fetchProperty;
-(void) fetchPropertyPerUser;
-(void) fetchPropertyPerCity:(NSString *) cityStr;
-(void) checkifFavorites:(PropertyList *) pList;
-(void) addFavorites:(PropertyList *) pList;
-(void) removeFavorites:(PropertyList *) pList;
-(void) fetchUserFavorites;
-(void) deleteProperty:(PropertyList *) pList;
//AddProperty
-(void) addProperty:(NSDictionary *) propertyDetails;
-(void) updateProperty:(NSDictionary *) propertyDetails :(NSString *) propertyObjID;
-(void) updatePropertyList:(PropertyList *)propertyList withDetails:(NSDictionary *)propertyDetails;

//Property Images
- (void) propertyImagesForPropertyList:(PropertyList *)propertyList;

//UploadImages
-(void) uploadImages:(NSMutableArray *) listImages :(NSString *) objID;
- (void)deleteImage:(PropertyImages *)image fromProperty:(PropertyList *)propertyList;

//Filtering
-(void) fetchLocationByCity;
-(void) FilterSearch:(NSDictionary *) dict;
- (void)FilterSearchPropertyType:(NSString *)type;

@end
