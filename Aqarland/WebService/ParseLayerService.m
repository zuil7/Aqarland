//
//  ParseLayerService.m
//  Aqarland
//
//  Created by Louise on 1/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "ParseLayerService.h"
#import "PFTwitterUtils+NativeTwitter.h"
#import <Accounts/Accounts.h>
#import "FHSTwitterEngine.h"
#import "PropertyList.h"
#import "AQUser.h"

#define mSuccess [NSNumber numberWithBool:1]
#define mFailed  [NSNumber numberWithBool:0]

#define sTwitterURL @"https://api.twitter.com/1.1/users/show.json?screen_name=%@"

static ParseLayerService *instance = nil;

@implementation ParseLayerService {
    AQResultBlock completionBlock;
    AQFailedBlock failureBlock;
    UserProfile *pfUserProfile;
    AQUser *aqUser;
}

+ (ParseLayerService *) sharedInstance {
    static dispatch_once_t disLock = 0;
    
    if (instance == nil) {
        dispatch_once(&disLock, ^{
            if (instance == nil) {
                NSLog(@"Initializing ServiceLayer");
                instance = [[ParseLayerService alloc] init];
            }
        });
    }
    
    return instance;
}

#pragma mark - Block Setters

- (void)setCompletionBlock:(AQResultBlock)aCompletionBlock {
	completionBlock = [aCompletionBlock copy];
}

- (void)setFailedBlock:(AQFailedBlock)aFailedBlock {
	failureBlock = [aFailedBlock copy];
}

- (void)reportSuccess:(id)results {
    if (completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(results);
        });
    }
}

- (void)reportFailure:(NSError *)error {
    if (failureBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock(error);
        });
    }
}

////////////////////////////////
#pragma mark - Sign Up Logic
////////////////////////////////

-(void) signUp:(NSDictionary *) profileInfo
{
    PFUser *user = [PFUser user];
    user.username = profileInfo[@"EmailAddress"];
    user.password = profileInfo[@"Password"];
    user.email = profileInfo[@"EmailAddress"];
    user[@"name"] =profileInfo[@"fullname"];
    user[@"loginType"] =profileInfo[@"loginType"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            [self createAccount:profileInfo];
        } else {
            [self reportFailure:error];
        }
    }];
}
////////////////////////////////
#pragma mark - Facebook Logic
////////////////////////////////
-(void) createAccount:(NSDictionary *) profileInfo
{
    PFUser *cUser = [PFUser currentUser];
    PFObject *post = [PFObject objectWithClassName:pUserProfile];
    post[@"user"] = cUser;
    post[@"fullName"] = profileInfo[@"fullname"];
    post[@"phoneNumber"]=profileInfo[@"PhoneNumber"];
    post[@"address"]=profileInfo[@"Street"];
    post[@"country"]=profileInfo[@"Country"];
    post[@"city"]=profileInfo[@"City"];
    post[@"postCode"]=profileInfo[@"PostCode"];
    post[@"latLong"]=profileInfo[@"LatLong"];
    
    
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            PFRelation *relation = [cUser relationForKey:@"userProfile"];
            [relation addObject:post];
            [cUser saveInBackground];
            
            [self reportSuccess:[NSNumber numberWithBool:succeeded]];
        }
        else
        {
            [self reportFailure:error];
        }
    }];
}

////////////////////////////////
#pragma mark - Create Account Via FB
////////////////////////////////
-(void) createAccountViaFB:(NSDictionary *) profileInfo
{
    NSLog(@"profileInfo>>> %@",profileInfo);
    PFUser *cUser = [PFUser currentUser];
    cUser[@"username"]=profileInfo[@"email"];
    cUser[@"email"]=profileInfo[@"email"];
    cUser[@"name"]= profileInfo[@"name"];
    cUser[@"loginType"] =profileInfo[@"loginType"];
   
    [cUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if(succeeded)
        {
            // Assume PFObject Check if user was previously created.
            PFQuery *query = [PFQuery queryWithClassName:pUserProfile];
            [query whereKey:@"user" equalTo:cUser];
            [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
             {
                 NSLog(@"pUserProfile %lu",(unsigned long)[result count]);
                 if([result count]==0)
                 {
                     PFObject *post = [PFObject objectWithClassName:pUserProfile];
                     post[@"user"] = cUser;
                     post[@"fullName"] = profileInfo[@"name"];
                     [post setObject:profileInfo[@"imgFile"] forKey:@"userAvatar"];
                                        
                     [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                      {
                          if (!error)
                          {
                              PFUser *user=[PFUser currentUser];
                              PFRelation *relation = [user relationForKey:@"userProfile"];
                              [relation addObject:post];
                              [user saveInBackground];
                              NSLog(@"user %@",user);
                              [self reportSuccess:user];
                          }
                          else
                          {
                              [self reportFailure:error];
                          }
                      }];
                  }else if([result count]==1)
                  {
                       PFUser *user=[PFUser currentUser];
                      [self reportSuccess:user];
                  }else
                  {
                       [self reportFailure:error];
                  }
            }];
          
        
        }else
        {
            [self reportFailure:error];
        }

    }];
   
}
////////////////////////////////
#pragma mark - Twitter Logic
////////////////////////////////
- (void)loginUserWithAccount:(ACAccount *)twitterAccount
{
    [PFTwitterUtils setNativeLogInSuccessBlock:^(PFUser *parseUser, NSString *userTwitterId, NSError *error) {
        [self onLoginSuccess:parseUser username:[twitterAccount username]];
    }];
    
    [PFTwitterUtils setNativeLogInErrorBlock:^(TwitterLogInError logInError) {
        NSError *error = [[NSError alloc] initWithDomain:nil code:logInError userInfo:@{@"logInErrorCode" : @(logInError)}];
        [self onLoginFailure:error];
    }];
    
    [PFTwitterUtils logInWithAccount:twitterAccount];
}

-(void) loginUserWithTwitterEngine
{
    //FHSTwitterEngine *twitterEngine = [FHSTwitterEngine sharedEngine];
    //FHSToken *token = [FHSTwitterEngine sharedEngine].accessToken;
    PF_Twitter *twitterUtil=[PFTwitterUtils twitter];

    [PFTwitterUtils logInWithTwitterId:twitterUtil.userId
                            screenName:twitterUtil.screenName
                             authToken:twitterUtil.authToken
                       authTokenSecret:twitterUtil.authTokenSecret
                                 block:^(PFUser *user, NSError *error) {
                                     if (user) {
                                         NSLog(@"authenticatedUsername %@",twitterUtil.screenName);
                                         [self onLoginSuccess:user username:twitterUtil.screenName];
                                     } else {
                                         [self onLoginFailure:error];
                                     }
                                 }];
}
#pragma mark - Twittter Private Method

- (void)onLoginSuccess:(PFUser *)user username:(NSString *) uName
{
    [self fetchDataForUser:user username:uName];
}
- (void)onLoginFailure:(NSError *)error
{
   
     [self reportFailure:error];
}

- (void)fetchDataForUser:(PFUser *)user username:(NSString *)twitterUsername
{
    NSString * requestString = [NSString stringWithFormat:sTwitterURL,twitterUsername];
    
    NSURL *verify = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
         NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (!error)
        {
            NSLog(@"result %@",resultDict);
            user.username = resultDict[@"screen_name"];
            user[@"name"]= resultDict[@"name"];
            user[@"loginType"] =mTwitterLogin;
            //user[@"profileDescription"] = resultDict[@"description"];
            //user[@"imageURL"] = [resultDict[@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (!error)
                 {
                     // Assume PFObject Check if user was previously created.
                     PFQuery *query = [PFQuery queryWithClassName:pUserProfile];
                     [query whereKey:@"user" equalTo:user];
                     [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
                      {
                          NSLog(@"pUserProfile %lu",(unsigned long)[result count]);
                          if([result count]==0)
                          {
                              PFObject *post = [PFObject objectWithClassName:pUserProfile];
                              post[@"user"] = user;
                              post[@"fullName"] = resultDict[@"name"];
                              
                              NSString *cleanProfileImageURL=[resultDict[@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
                              NSLog(@"cleanProfileImageURL %@",cleanProfileImageURL);
                              NSURL *pictureURL = [NSURL URLWithString:cleanProfileImageURL];
                              NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                              PFFile *imageFile = [PFFile fileWithName:@"avatar.png" data:imageData];
                              [post setObject:imageFile forKey:@"userAvatar"];
                              
                              [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                               {
                                   if (!error)
                                   {
                                       PFUser *user=[PFUser currentUser];
                                       PFRelation *relation = [user relationForKey:@"userProfile"];
                                       [relation addObject:post];
                                       [user saveInBackground];
                                       
                                       [self reportSuccess:user];
                                   }
                                   else
                                   {
                                       [self reportFailure:error];
                                   }
                               }];
                          }else if([result count]==1)
                          {
                              [self reportSuccess:mSuccess];
                          }else
                          {
                              [self reportFailure:error];
                          }
                      }];
                     

                 }
                 else
                 {
                     [self reportFailure:error];
                 }
             }];
        }
    }];
    
}

////////////////////////////////
#pragma mark - User Profile
////////////////////////////////

- (void)fetchCurrentUserProfile {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:pUserProfile];
    [query whereKey:@"user" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                pfUserProfile = objects[0];
                
                NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
                [userDictionary setObject:pfUserProfile forKey:pUserProfile];
                [userDictionary setObject:[PFUser currentUser] forKey:pUser];
                
                [self reportSuccess:userDictionary];
            } else {
                NSError *error;
                NSMutableDictionary *errorDetails = [[NSMutableDictionary alloc] init];
                NSString *errorMsg = @"Unable to fetch user info. Please try again.";
                [errorDetails setValue:errorMsg forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:@"Error" code:500 userInfo:errorDetails];
                
                [self reportFailure:error];
            }
        } else {
            [self reportFailure:error];
        }
    }];
}

////////////////////////////////
#pragma mark - Login Request
////////////////////////////////
- (void) requestLogin:(NSString *)username passWord:(NSString *) pass {
    [PFUser logInWithUsernameInBackground:username password:pass
                                    block:^(PFUser *user, NSError *error)
     {
         NSLog(@"user %@",user);
        if (user) {
            [self reportSuccess:user];
        } else {
            [self reportFailure:error];
        }
    }];
}
////////////////////////////////
#pragma mark - FetchProperty Per User
////////////////////////////////
-(void) fetchPropertyPerUser
{
    PFUser *cUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query whereKey:@"user" equalTo:cUser];
    [query orderByDescending:@"createdAt"];
    //query.limit = 10;
    [query includeKey:@"propertyImgArr"];
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
     {
         
         if(!error)
         {
             
             NSMutableArray *propertyListArr=[[NSMutableArray alloc] init];
             for (PFObject *pResult in result)
             {
                 PropertyList *property=[[PropertyList alloc] init];
                 NSLog(@"comment %@",pResult);
                 if ([pResult objectId].length!=0)
                 {
                     property.m_objectID=[pResult objectId];
                 }
                 if (pResult[@"amenities"] != [NSNull null])
                 {
                     property.m_amenities=pResult[@"amenities"];
                 }
                 if (pResult[@"building"] != [NSNull null])
                 {
                     property.m_building=pResult[@"building"];
                 }
                 if (pResult[@"city"] != [NSNull null])
                 {
                     property.m_city=pResult[@"city"];
                 }
                 if (pResult[@"description"] != [NSNull null])
                 {
                     property.m_description=pResult[@"description"];
                 }
                 if (pResult[@"houseNumber"] != [NSNull null])
                 {
                     property.m_houseNumber=pResult[@"houseNumber"];
                 }
                 if (pResult[@"latLong"] != [NSNull null])
                 {
                     property.m_latLong=pResult[@"latLong"];
                 }
                 if (pResult[@"numberOfBaths"] != [NSNull null])
                 {
                     property.m_numberOfBaths=pResult[@"numberOfBaths"];
                 }
                 if (pResult[@"numberOfBedrooms"] != [NSNull null])
                 {
                     property.m_numberOfBedrooms=pResult[@"numberOfBedrooms"];
                 }
                 if (pResult[@"postCode"] != [NSNull null])
                 {
                     property.m_postCode=pResult[@"postCode"];
                 }
                 if (pResult[@"nPropertySize"] != [NSNull null])
                 {
                     property.m_propertySize=pResult[@"nPropertySize"];
                 }
                 if (pResult[@"propertyType"] != [NSNull null])
                 {
                     property.m_propertyType=pResult[@"propertyType"];
                 }
                 if (pResult[@"street"] != [NSNull null])
                 {
                     property.m_street=pResult[@"street"];
                 }
                 if (pResult[@"unit"] != [NSNull null])
                 {
                     property.m_unit=pResult[@"unit"];
                 }
                 if (pResult[@"user"] != [NSNull null])
                 {
                     property.user=pResult[@"user"];
                 }
                 if (pResult[@"propertyImgArr"] != [NSNull null])
                 {
                     property.propertyImages=pResult[@"propertyImgArr"];
                 }
                 if (pResult[@"price"] != [NSNull null])
                 {
                     property.m_price=pResult[@"price"];
                 }
                 if (pResult[@"ofType"] != [NSNull null])
                 {
                     property.m_ofType=pResult[@"ofType"];
                 }

                 [propertyListArr addObject:property];
             }
             
             [self reportSuccess:propertyListArr];
         }else
         {
             [self reportFailure:error];
         }
         
     }];
}

////////////////////////////////
#pragma mark - FetchProperty
////////////////////////////////
-(void) fetchProperty
{
    //PFUser *cUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    //[query whereKey:@"user" equalTo:cUser];
    // Retrieve the most recent ones
    [query orderByDescending:@"createdAt"];
    
    // Only retrieve the last ten
    //query.limit = 10;
    [query includeKey:@"propertyImgArr"];
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
    {
        
        if(!error)
        {
            
            NSMutableArray *propertyListArr=[[NSMutableArray alloc] init];
            for (PFObject *pResult in result)
            {
                PropertyList *property=[[PropertyList alloc] init];
                NSLog(@"comment %@",pResult);
                if ([pResult objectId].length!=0)
                {
                    property.m_objectID=[pResult objectId];
                }
                if (pResult[@"amenities"] != [NSNull null])
                {
                    property.m_amenities=pResult[@"amenities"];
                }
                if (pResult[@"building"] != [NSNull null])
                {
                    property.m_building=pResult[@"building"];
                }
                if (pResult[@"city"] != [NSNull null])
                {
                    property.m_city=pResult[@"city"];
                }
                if (pResult[@"description"] != [NSNull null])
                {
                    property.m_description=pResult[@"description"];
                }
                if (pResult[@"houseNumber"] != [NSNull null])
                {
                    property.m_houseNumber=pResult[@"houseNumber"];
                }
                if (pResult[@"latLong"] != [NSNull null])
                {
                    property.m_latLong=pResult[@"latLong"];
                }
                if (pResult[@"numberOfBaths"] != [NSNull null])
                {
                    property.m_numberOfBaths=pResult[@"numberOfBaths"];
                }
                if (pResult[@"numberOfBedrooms"] != [NSNull null])
                {
                    property.m_numberOfBedrooms=pResult[@"numberOfBedrooms"];
                }
                if (pResult[@"postCode"] != [NSNull null])
                {
                    property.m_postCode=pResult[@"postCode"];
                }
                if (pResult[@"nPropertySize"] != [NSNull null])
                {
                    property.m_propertySize=pResult[@"nPropertySize"];
                }
                if (pResult[@"propertyType"] != [NSNull null])
                {
                    property.m_propertyType=pResult[@"propertyType"];
                }
                if (pResult[@"street"] != [NSNull null])
                {
                    property.m_street=pResult[@"street"];
                }
                if (pResult[@"unit"] != [NSNull null])
                {
                    property.m_unit=pResult[@"unit"];
                }
                if (pResult[@"price"] != [NSNull null])
                {
                    property.m_price=pResult[@"price"];
                }
                if (pResult[@"ofType"] != [NSNull null])
                {
                    property.m_ofType=pResult[@"ofType"];
                }
                if (pResult[@"user"] != [NSNull null])
                {
                    property.user=pResult[@"user"];
                }
                if (pResult[@"propertyImgArr"] != [NSNull null])
                {
                    property.propertyImages=pResult[@"propertyImgArr"];
                }
                if(pResult[@"user"])
                {
                    property.user=pResult[@"user"];
                }
                [propertyListArr addObject:property];
            }
            
            [self reportSuccess:propertyListArr];
        }else
        {
            [self reportFailure:error];
        }
        
    }];
}

-(void) fetchPropertyPerCity:(NSString *) cityStr
{
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query whereKey:@"city" equalTo:cityStr];
    [query orderByDescending:@"createdAt"];
    //query.limit = 10;
    [query includeKey:@"propertyImgArr"];
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
    {
        if(!error)
        {
            NSMutableArray *propertyListArr=[[NSMutableArray alloc] init];
            for (PFObject *pResult in result)
            {
                PropertyList *property=[[PropertyList alloc] init];
                NSLog(@"comment %@",pResult);
                if ([pResult objectId].length!=0)
                {
                    property.m_objectID=[pResult objectId];
                }
                if (pResult[@"amenities"] != [NSNull null])
                {
                    property.m_amenities=pResult[@"amenities"];
                }
                if (pResult[@"building"] != [NSNull null])
                {
                    property.m_building=pResult[@"building"];
                }
                if (pResult[@"city"] != [NSNull null])
                {
                    property.m_city=pResult[@"city"];
                }
                if (pResult[@"description"] != [NSNull null])
                {
                    property.m_description=pResult[@"description"];
                }
                if (pResult[@"houseNumber"] != [NSNull null])
                {
                    property.m_houseNumber=pResult[@"houseNumber"];
                }
                if (pResult[@"latLong"] != [NSNull null])
                {
                    property.m_latLong=pResult[@"latLong"];
                }
                if (pResult[@"numberOfBaths"] != [NSNull null])
                {
                    property.m_numberOfBaths=pResult[@"numberOfBaths"];
                }
                if (pResult[@"numberOfBedrooms"] != [NSNull null])
                {
                    property.m_numberOfBedrooms=pResult[@"numberOfBedrooms"];
                }
                if (pResult[@"postCode"] != [NSNull null])
                {
                    property.m_postCode=pResult[@"postCode"];
                }
                if (pResult[@"nPropertySize"] != [NSNull null])
                {
                    property.m_propertySize=pResult[@"nPropertySize"];
                }
                if (pResult[@"propertyType"] != [NSNull null])
                {
                    property.m_propertyType=pResult[@"propertyType"];
                }
                if (pResult[@"street"] != [NSNull null])
                {
                    property.m_street=pResult[@"street"];
                }
                if (pResult[@"unit"] != [NSNull null])
                {
                    property.m_unit=pResult[@"unit"];
                }
                if (pResult[@"price"] != [NSNull null])
                {
                    property.m_price=pResult[@"price"];
                }
                if (pResult[@"user"] != [NSNull null])
                {
                    property.user=pResult[@"user"];
                }
                if (pResult[@"propertyImgArr"] != [NSNull null])
                {
                    property.propertyImages=pResult[@"propertyImgArr"];
                }
                if(pResult[@"user"])
                {
                    property.user=pResult[@"user"];
                }
               
                
                [propertyListArr addObject:property];
            }
            
            [self reportSuccess:propertyListArr];
        }else
        {
              [self reportFailure:error];
        }
        
    }];
}


-(void) checkifFavorites:(PropertyList *) pList
{
    __block NSMutableArray *arrayTmp=[[NSMutableArray alloc] init];
    __block PFObject *resultList;

    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query getObjectInBackgroundWithId:pList.m_objectID block:^(PFObject *result, NSError *error)
     {
         PFUser *cUser = [PFUser currentUser];
         resultList=result;
         NSLog(@"resultList ID %@",[resultList objectId]);
         PFQuery *queryUser = [PFQuery queryWithClassName:pUserProfile];
         [queryUser whereKey:@"user" equalTo:cUser];
         [queryUser findObjectsInBackgroundWithBlock:^(NSArray *userResult, NSError *error)
          {
              if(!error && userResult.count!=0)
              {
                  for (int i=0; i<[userResult count]; i++)
                  {
                      NSDictionary *dict=[userResult objectAtIndex:i];
                      arrayTmp=[NSMutableArray arrayWithArray:dict[@"favoriteArray"]];
                      NSLog(@"arrayTmp %@",arrayTmp);
                      
                       NSArray *arr=[arrayTmp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId=%@",[resultList objectId]]];
                       NSLog(@"arr %@",arr);
                      if ([arr count]!=0)
                      {
                          [self reportSuccess:[NSNumber numberWithBool:YES]];
                      }else
                      {
                          [self reportFailure:error];
                      }
                      
                  }
                
              }
              
          }];
         
     }];
     
     

}

-(void) addFavorites:(PropertyList *) pList
{
  
    __block NSMutableArray *arrayTmp=[[NSMutableArray alloc] init];
    __block PFObject *resultList;
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query getObjectInBackgroundWithId:pList.m_objectID block:^(PFObject *result, NSError *error)
     {
         PFUser *cUser = [PFUser currentUser];
         resultList=result;
         NSLog(@"resultList ID %@",[resultList objectId]);
         PFQuery *queryUser = [PFQuery queryWithClassName:pUserProfile];
         [queryUser whereKey:@"user" equalTo:cUser];
         [queryUser findObjectsInBackgroundWithBlock:^(NSArray *userResult, NSError *error)
          {
              NSLog(@"userResult %@",userResult);
              if(!error && userResult.count!=0)
              {
                  NSString *objStr;
                  for (PFObject *pResultObj in userResult)
                  {
                      objStr=[pResultObj objectId];
                  }
                  
                  for (int i=0; i<[userResult count]; i++)
                  {
                      NSDictionary *dict=[userResult objectAtIndex:i];
                      arrayTmp=[NSMutableArray arrayWithArray:dict[@"favoriteArray"]];
                  }
                  
                     NSArray *arr=[arrayTmp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId=%@",[resultList objectId]]];
                      NSLog(@"arr %@",arr);
                          if([arr count]==0)
                          {
                              [arrayTmp addObject:resultList];
                              NSLog(@"arrayTmp %@",arrayTmp);
                              PFQuery *query1 = [PFQuery queryWithClassName:pUserProfile];
                              [query1 getObjectInBackgroundWithId:objStr block:^(PFObject *userProfileResult, NSError *error)
                               {
                                   userProfileResult[@"favoriteArray"] = arrayTmp;
                                   [userProfileResult saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                    {
                                        if (!error)
                                        {
                                            NSLog(@"userProfileResult %@",userProfileResult);
                                            [self reportSuccess:[NSNumber numberWithBool:succeeded]];
                                        }
                                        else
                                        {
                                            [self reportFailure:error];
                                        }
                                    }];
                               }];
                          }else
                          {
                               [self reportSuccess:[NSNumber numberWithBool:YES]];
                          }
              }
          }];
     }];
    
}
-(void) removeFavorites:(PropertyList *) pList
{
    __block NSMutableArray *arrayTmp=[[NSMutableArray alloc] init];
    __block PFObject *resultList;
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query getObjectInBackgroundWithId:pList.m_objectID block:^(PFObject *result, NSError *error)
     {
         PFUser *cUser = [PFUser currentUser];
         resultList=result;
         NSLog(@"resultList ID %@",[resultList objectId]);
         PFQuery *queryUser = [PFQuery queryWithClassName:pUserProfile];
         [queryUser whereKey:@"user" equalTo:cUser];
         [queryUser findObjectsInBackgroundWithBlock:^(NSArray *userResult, NSError *error)
          {
              NSLog(@"userResult %@",userResult);
              if(!error && userResult.count!=0)
              {
                  NSString *objStr;
                  for (PFObject *pResultObj in userResult)
                  {
                      objStr=[pResultObj objectId];
                  }
                  
                  for (int i=0; i<[userResult count]; i++)
                  {
                      NSDictionary *dict=[userResult objectAtIndex:i];
                      arrayTmp=[NSMutableArray arrayWithArray:dict[@"favoriteArray"]];
                  }
                  
                  NSArray *arr=[arrayTmp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId=%@",[resultList objectId]]];
                  NSLog(@"arr %@",arr);
                  if([arr count]!=0)
                  {
                      [arrayTmp removeObjectsInArray:[arrayTmp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId=%@",[resultList objectId]]]];
                      NSLog(@"arrayTmp %@",arrayTmp);
                      PFQuery *query1 = [PFQuery queryWithClassName:pUserProfile];
                      [query1 getObjectInBackgroundWithId:objStr block:^(PFObject *userProfileResult, NSError *error)
                       {
                           userProfileResult[@"favoriteArray"] = arrayTmp;
                           [userProfileResult saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                            {
                                if (!error)
                                {
                                    NSLog(@"userProfileResult %@",userProfileResult);
                                    [self reportSuccess:[NSNumber numberWithBool:succeeded]];
                                }
                                else
                                {
                                    [self reportFailure:error];
                                }
                            }];
                       }];
                  }else
                  {
                      [self reportSuccess:[NSNumber numberWithBool:YES]];
                  }
              }
          }];
     }];
}

-(void) fetchUserFavorites
{
    PFUser *cUser = [PFUser currentUser];
    PFQuery *queryUser = [PFQuery queryWithClassName:pUserProfile];
    [queryUser whereKey:@"user" equalTo:cUser];
    [queryUser includeKey:@"favoriteArray"];
    [queryUser includeKey:@"favoriteArray.propertyImgArr"];
    [queryUser includeKey:@"favoriteArray.user"];
    [queryUser findObjectsInBackgroundWithBlock:^(NSArray *userResult, NSError *error)
     {
         NSLog(@"userResult %@",userResult);
         if(!error && userResult.count!=0)
         {
             for (int i=0; i<[userResult count]; i++)
             {
                 NSDictionary *dict=[userResult objectAtIndex:i];
                 NSLog(@"dict %@",dict);
                 NSArray *tempArr=[NSArray arrayWithArray:dict[@"favoriteArray"]];
                
                 if ([tempArr count]!=0)
                 {
                     NSMutableArray *propertyListArr=[[NSMutableArray alloc] init];
                     for (PFObject *pResult in tempArr)
                     {
                         PropertyList *property=[[PropertyList alloc] init];
                         NSLog(@"comment %@",pResult);
                         if ([pResult objectId].length!=0)
                         {
                             property.m_objectID=[pResult objectId];
                         }
                         if (pResult[@"amenities"] != [NSNull null])
                         {
                             property.m_amenities=pResult[@"amenities"];
                         }
                         if (pResult[@"building"] != [NSNull null])
                         {
                             property.m_building=pResult[@"building"];
                         }
                         if (pResult[@"city"] != [NSNull null])
                         {
                             property.m_city=pResult[@"city"];
                         }
                         if (pResult[@"description"] != [NSNull null])
                         {
                             property.m_description=pResult[@"description"];
                         }
                         if (pResult[@"houseNumber"] != [NSNull null])
                         {
                             property.m_houseNumber=pResult[@"houseNumber"];
                         }
                         if (pResult[@"latLong"] != [NSNull null])
                         {
                             property.m_latLong=pResult[@"latLong"];
                         }
                         if (pResult[@"numberOfBaths"] != [NSNull null])
                         {
                             property.m_numberOfBaths=pResult[@"numberOfBaths"];
                         }
                         if (pResult[@"numberOfBedrooms"] != [NSNull null])
                         {
                             property.m_numberOfBedrooms=pResult[@"numberOfBedrooms"];
                         }
                         if (pResult[@"postCode"] != [NSNull null])
                         {
                             property.m_postCode=pResult[@"postCode"];
                         }
                         if (pResult[@"nPropertySize"] != [NSNull null])
                         {
                             property.m_propertySize=pResult[@"nPropertySize"];
                         }
                         if (pResult[@"propertyType"] != [NSNull null])
                         {
                             property.m_propertyType=pResult[@"propertyType"];
                         }
                         if (pResult[@"street"] != [NSNull null])
                         {
                             property.m_street=pResult[@"street"];
                         }
                         if (pResult[@"unit"] != [NSNull null])
                         {
                             property.m_unit=pResult[@"unit"];
                         }
                         if (pResult[@"user"] != [NSNull null])
                         {
                             NSLog(@"User %@",pResult[@"user"]);
                             property.user=pResult[@"user"];
                         }
                         if (pResult[@"propertyImgArr"] != [NSNull null])
                         {
                             NSLog(@"propertyImgArr %@",pResult[@"propertyImgArr"]);
                             property.propertyImages=pResult[@"propertyImgArr"];
                         }
                         if (pResult[@"price"] != [NSNull null])
                         {
                             property.m_price=pResult[@"price"];
                         }
                         
                         [propertyListArr addObject:property];
                     }
                     
                      [self reportSuccess:propertyListArr];
                     break;
                 }
                 else
                 {
                      [self reportFailure:error];
                 }
                 
                 

             }
         }
         
     }];

}

-(void) deleteProperty:(PropertyList *) pList
{
    __block NSMutableArray *arrayTmp=[[NSMutableArray alloc] init];
    NSLog(@"object ID %@",pList.m_objectID);
    PFUser *cUser = [PFUser currentUser];
    PFQuery *queryUser = [PFQuery queryWithClassName:pUserProfile];
    [queryUser whereKey:@"user" equalTo:cUser];
    [queryUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
        NSLog(@"object %@",object);
        arrayTmp= [NSMutableArray arrayWithArray:object[@"favoriteArray"]];
        NSLog(@"arrayTmp %@",arrayTmp);
        if([arrayTmp count]!=0)
        {
            NSArray *arr=[arrayTmp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId=%@",pList.m_objectID]];
            NSLog(@"arr %@",arr);
            if([arr count]!=0)
            {
                [arrayTmp removeObjectsInArray:[arrayTmp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId=%@",pList.m_objectID]]];
                object[@"favoriteArray"]=arrayTmp;

                //Query in Property List
                PFQuery *queryPropertyList = [PFQuery queryWithClassName:pPropertyList];
                [queryPropertyList whereKey:@"objectId" equalTo:pList.m_objectID];
                [queryPropertyList getFirstObjectInBackgroundWithBlock:^(PFObject *objectProperty, NSError *error)
                 {
                     //Deleting all images under property object ID
                     PFQuery *queryPropertyImage = [PFQuery queryWithClassName:pPropertyImage];
                     [queryPropertyImage whereKey:@"propertyList" equalTo:objectProperty];
                     [queryPropertyImage findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                      {
                          for (PFObject *obj in objects)
                          {
                              [obj deleteInBackground];
                          }
                     }];

                     [objectProperty deleteInBackground];
                     
                 }];
                
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                {
                    if (!error)
                    {
                          [self reportSuccess:[NSNumber numberWithBool:succeeded]];
                    }else
                    {
                        [self reportFailure:error];

                    }
                }];
                
            }else
            {
                //Not Favorite
                
                //Query in Property List
                PFQuery *queryPropertyList = [PFQuery queryWithClassName:pPropertyList];
                [queryPropertyList whereKey:@"objectId" equalTo:pList.m_objectID];
                [queryPropertyList getFirstObjectInBackgroundWithBlock:^(PFObject *objectProperty, NSError *error)
                 {
                     //Deleting all images under property object ID
                     PFQuery *queryPropertyImage = [PFQuery queryWithClassName:pPropertyImage];
                     [queryPropertyImage whereKey:@"propertyList" equalTo:objectProperty];
                     [queryPropertyImage findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                      {
                          for (PFObject *obj in objects)
                          {
                              [obj deleteInBackground];
                          }
                      }];
                     
                     [objectProperty deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if(!error)
                         {
                             [self reportSuccess:[NSNumber numberWithBool:succeeded]];
                         }else
                         {
                          [self reportFailure:error];
                         }
                     }];
                     
                 }];
                
            }
            
            
        }
    }];
    
//    [queryUser get:^(NSArray *userResult, NSError *error)
//     {
//         
//         if (!error)
//         {
//             for (int i=0; i<[userResult count]; i++)
//             {
//                 NSDictionary *dict=[userResult objectAtIndex:i];
//                 NSLog(@"dict %@",dict);
//                 arrayTmp= [NSMutableArray arrayWithArray:dict[@"favoriteArray"]];
//                  NSLog(@"tempArr %@",arrayTmp);
//                 if([arrayTmp count]!=0)
//                 {
//                 
//                      NSArray *arr=[arrayTmp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId=%@",pList.m_objectID]];
//                     
//                 }
//             }
//         }
//         [self reportSuccess:[NSNumber numberWithBool:1]];
//     }];
//    
    
    
    /*
    __block PFObject *propertyListObj;
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query includeKey:@"user"];
    [query includeKey:@"propertyImgArr"];
    [query whereKey:@"objectId" equalTo:pList.m_objectID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully %@", result);
            // Do something with the found objects
            for (int i=0; i<[result count]; i++)
            {
                NSDictionary *dict=[result objectAtIndex:i];
                 NSLog(@"dict %@", dict);
                propertyListObj=[result objectAtIndex:i];
                PFObject *userObj=dict[@"user"];
                
                NSArray *imgArr=dict[@"propertyImgArr"];
                for (PFObject *imgObj in imgArr)
                {
                    [imgObj deleteInBackground];
                }
                
                NSLog(@"userObj %@",[userObj objectId]);
                PFRelation *relation = [userObj relationForKey:@"userProfile"];
                
                PFQuery *querytemp = relation.query;
                [query includeKey:@"favoriteArray"];
                [querytemp whereKey:@"user" equalTo:userObj];
                [querytemp findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
                {
                    NSLog(@"result %@",result);
                    NSLog(@"result %d",[result count]);
                    if(!error)
                    {
                        for (int i=0; i<[result count]; i++)
                        {
                            NSDictionary *dict=[result objectAtIndex:i];
                            NSArray *tempArr=dict[@"favoriteArray"];
                          
                            NSLog(@"tempArr %@",tempArr);
                                for (PFObject *favoriteObj in tempArr)
                                {
                                    [favoriteObj deleteInBackground];
                                }
                        }
                    }else
                        
                    {
                         [self reportFailure:error];
                    }
                    
                    
                    
                }];

                
                NSLog(@"relation %@", relation);
                [propertyListObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                {
                    if (!error)
                    {
                        [self reportSuccess:[NSNumber numberWithBool:succeeded]];
                    }else
                    {
                      [self reportFailure:error];
                    }
                    
                }];
            }
        } else
        {
            [self reportFailure:error];
        }
    }];*/

}
////////////////////////////////
#pragma mark - Add Property
////////////////////////////////
-(void) addProperty:(NSDictionary *) propertyDetails
{
    PFUser *cUser = [PFUser currentUser];
    PFObject *post = [PFObject objectWithClassName:pPropertyList];
   
    post[@"unit"] = propertyDetails[@"unit"];
    post[@"houseNumber"]=propertyDetails[@"houseNum"];
    post[@"building"]=propertyDetails[@"bldg"];
    post[@"street"]=propertyDetails[@"street"];
    post[@"city"]=propertyDetails[@"city"];
    post[@"postCode"]=propertyDetails[@"postcode"];
    
    post[@"propertyType"]=propertyDetails[@"propertyType"];
    float fPropertySize=[propertyDetails[@"nPropertySize"] floatValue];
    post[@"nPropertySize"]=[NSNumber numberWithFloat:fPropertySize];
    post[@"numberOfBedrooms"]=propertyDetails[@"numberOfBedrooms"];
    post[@"numberOfBaths"]=propertyDetails[@"numberOfBaths"];
    post[@"amenities"]=propertyDetails[@"amenities"];
    
    if([propertyDetails[@"ofType"] isEqualToString:@"For Rent"])
    {
        post[@"ofType"]=@"Rent";
    }
    else
    {
        post[@"ofType"]=@"Sale";
    }
   
    post[@"price"]=propertyDetails[@"price"];
    post[@"description"]=propertyDetails[@"description"];
    
    post[@"user"] = cUser;
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            PFRelation *relation = [cUser relationForKey:@"propertyList"];
            [relation addObject:post];
            [cUser saveInBackground];
            NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:succeeded],@"flag",
                [post objectId],@"propertyObjID",nil];
            [self reportSuccess:dict];
        }
        else
        {
            [self reportFailure:error];
        }
    }];

}
////////////////////////////////
#pragma mark - Update Property
////////////////////////////////
-(void) updateProperty:(NSDictionary *) propertyDetails :(NSString *) propertyObjID
{
    NSLog(@"propertyObjID %@",propertyObjID);
    NSLog(@"propertyDetails %@",propertyDetails);
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    
    [query getObjectInBackgroundWithId:propertyObjID block:^(PFObject *property, NSError *error) {
        
        property[@"street"] = propertyDetails[@"Street"];
        property[@"city"] = propertyDetails[@"City"];
        property[@"postCode"] = propertyDetails[@"ZIP"];
        property[@"latLong"] = propertyDetails[@"latLong"];
        NSLog(@"propertyDetails %@",property);
        [property saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                [self reportSuccess:[NSNumber numberWithBool:succeeded]];
            }
            else
            {
                [self reportFailure:error];
            }
        }];
        
    }];
}

- (void) updatePropertyList:(PropertyList *)propertyList withDetails:(NSDictionary *)propertyDetails {
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query getObjectWithId:propertyList.m_objectID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if (object) {
                
                object[@"amenities"] = propertyDetails[@"amenities"];
                object[@"building"] = propertyDetails[@"bldg"];
                object[@"city"] = propertyDetails[@"city"];
                object[@"description"] = propertyDetails[@"description"];
                object[@"houseNumber"] = propertyDetails[@"houseNum"];
                float fPropertySize=[propertyDetails[@"nPropertySize"] floatValue];
                object[@"nPropertySize"] = [NSNumber numberWithFloat:fPropertySize];
                object[@"numberOfBaths"] = propertyDetails[@"numberOfBaths"];
                object[@"numberOfBedrooms"] = propertyDetails[@"numberOfBedrooms"];
                object[@"postCode"] = propertyDetails[@"postcode"];
                object[@"propertyType"] = propertyDetails[@"propertyType"];
                object[@"street"] = propertyDetails[@"street"];
                object[@"unit"] = propertyDetails[@"unit"];

                if([propertyDetails[@"ofType"] isEqualToString:@"For Rent"])
                {
                    object[@"ofType"]=@"Rent";
                }
                else
                {
                    object[@"ofType"]=@"Sale";
                }
                object[@"price"] = propertyDetails[@"price"];
                object[@"updatedAt"] = [NSDate date];
                
                [object saveEventually:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [self reportSuccess:[NSNumber numberWithBool:succeeded]];
                    } else {
                        [self reportFailure:error];;
                    }
                }];
            }
        }
        else
        {
            [self reportFailure:error];;
        }
        
    }];
}

////////////////////////////////
#pragma mark - Property Images
////////////////////////////////

- (void) propertyImagesForPropertyList:(PropertyList *)propertyList {
    PFQuery *query = [PFQuery queryWithClassName:pPropertyImage];
    PFObject *property = [PFObject objectWithoutDataWithClassName:pPropertyList objectId:propertyList.m_objectID];
    [query whereKey:@"propertyList" equalTo:property];
    [query includeKey:@"propertyList"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self reportSuccess:objects];
        } else {
            [self reportFailure:error];
        }
    }];
}

////////////////////////////////
#pragma mark - Upload Images
////////////////////////////////
-(void) uploadImages:(NSMutableArray *) listImages :(NSString *) objID
{
    PFUser *cUser = [PFUser currentUser];
    NSLog(@"cUser %@",cUser);
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query whereKey:@"objectId" equalTo:objID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error){
     if([result count]!=0)
     {
         for (int i=0; i<[listImages count]; i++)
         {
             UIImage *image=(UIImage *)[listImages objectAtIndex:i];
             if ([image isKindOfClass:[UIImage class]]) {
                 NSData *imageData = UIImageJPEGRepresentation(image,0.8);
                 PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
                 PFObject *userPhoto = [PFObject objectWithClassName:pPropertyImage];
                 NSString *strID;
                 userPhoto[@"propertyImg"]  = imageFile;
                 for (PFObject *object in result)
                 {
                     userPhoto[@"propertyList"] = object;
                     strID=[object objectId];
                 }
                 NSLog(@"strID %@",strID);
                 userPhoto[@"user"]=cUser;
                 [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if(error)
                      {
                          [self reportFailure:error];
                          
                      }else
                      {
                          PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
                          [query getObjectInBackgroundWithId:strID block:^(PFObject *result, NSError *error) {
                              PFRelation *relation = [result relationForKey:@"propertyImages"];
                              [relation addObject:userPhoto];
                              
                              NSMutableArray *array =  [NSMutableArray array];
                              array = [result[@"propertyImgArr"] mutableCopy];
                              if(!array)
                              {
                                  array =  [NSMutableArray array];
                              }
                              [array addObject:userPhoto];
                              result[@"propertyImgArr"] = array;
                              [result saveInBackground];
                              
                              
                          }];
                          NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:
                                              strID,@"propertyObjID",
                                              [NSNumber numberWithBool:succeeded],@"flag",
                                              nil];
                          [self reportSuccess:dict];
                      }
                  }];
                }
             }
        }
    }];

}

- (void)deleteImage:(PropertyImages *)image fromProperty:(PropertyList *)propertyList {
    PFQuery *query = [PFQuery queryWithClassName:pPropertyImage];
    [query whereKey:@"objectId" equalTo:[image valueForKey:@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [object delete];
            }
            [self reportSuccess:nil];
        }
        else
        {
            [self reportFailure:error];
        }
    }];

}

////////////////////////////////
#pragma mark - Filtering
////////////////////////////////
-(void) fetchLocationByCity
{
    
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query selectKeys:@[@"city"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
     {
         if (!error)
         {
             NSMutableArray *locationCityArr=[[NSMutableArray alloc] init];
             for (PFObject *pResult in result)
             {
                 NSString *cityStr;
                 if (pResult[@"city"] != [NSNull null])
                 {
                     cityStr=pResult[@"city"];
                 }
                 
                 [locationCityArr addObject:cityStr];
             }
             NSArray *newArr =  [[NSSet setWithArray:locationCityArr] allObjects];
             [self reportSuccess:newArr];
             
         }else
         {
             [self reportFailure:error];
         }
     }];
}



////////////////////////////////
#pragma mark - Filter Search
////////////////////////////////
-(void) FilterSearch:(NSDictionary *) dict
{
    
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query whereKey:@"city" equalTo:dict[@"city"]];
    [query whereKey:@"propertyType" equalTo:dict[@"pType"]];
    float val=[dict[@"pSize"] floatValue];
    [query whereKey:@"nPropertySize" lessThanOrEqualTo:@(val)];
    
    [query includeKey:@"propertyImgArr"];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
     {
         if(!error)
         {
             
             NSMutableArray *propertyListArr=[[NSMutableArray alloc] init];
             for (PFObject *pResult in result)
             {
                 PropertyList *property=[[PropertyList alloc] init];
                 NSLog(@"comment %@",pResult);
                 if ([pResult objectId].length!=0)
                 {
                     property.m_objectID=[pResult objectId];
                 }
                 if (pResult[@"amenities"] != [NSNull null])
                 {
                     property.m_amenities=pResult[@"amenities"];
                 }
                 if (pResult[@"building"] != [NSNull null])
                 {
                     property.m_building=pResult[@"building"];
                 }
                 if (pResult[@"city"] != [NSNull null])
                 {
                     property.m_city=pResult[@"city"];
                 }
                 if (pResult[@"description"] != [NSNull null])
                 {
                     property.m_description=pResult[@"description"];
                 }
                 if (pResult[@"houseNumber"] != [NSNull null])
                 {
                     property.m_houseNumber=pResult[@"houseNumber"];
                 }
                 if (pResult[@"latLong"] != [NSNull null])
                 {
                     property.m_latLong=pResult[@"latLong"];
                 }
                 if (pResult[@"numberOfBaths"] != [NSNull null])
                 {
                     property.m_numberOfBaths=pResult[@"numberOfBaths"];
                 }
                 if (pResult[@"numberOfBedrooms"] != [NSNull null])
                 {
                     property.m_numberOfBedrooms=pResult[@"numberOfBedrooms"];
                 }
                 if (pResult[@"postCode"] != [NSNull null])
                 {
                     property.m_postCode=pResult[@"postCode"];
                 }
                 if (pResult[@"nPropertySize"] != [NSNull null])
                 {
                     property.m_propertySize=pResult[@"nPropertySize"];
                 }
                 if (pResult[@"propertyType"] != [NSNull null])
                 {
                     property.m_propertyType=pResult[@"propertyType"];
                 }
                 if (pResult[@"street"] != [NSNull null])
                 {
                     property.m_street=pResult[@"street"];
                 }
                 if (pResult[@"unit"] != [NSNull null])
                 {
                     property.m_unit=pResult[@"unit"];
                 }
                 if (pResult[@"user"] != [NSNull null])
                 {
                     property.user=pResult[@"user"];
                 }
                 if (pResult[@"propertyImgArr"] != [NSNull null])
                 {
                     property.propertyImages=pResult[@"propertyImgArr"];
                 }
                 if (pResult[@"price"] != [NSNull null])
                 {
                     property.m_price=pResult[@"price"];
                 }
                 
                 [propertyListArr addObject:property];
             }
             
             [self reportSuccess:propertyListArr];
         }else
         {
             [self reportFailure:error];
         }
     }];

}

- (void)FilterSearchPropertyType:(NSString *)type {
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query whereKey:@"propertyType" equalTo:type];
    [query includeKey:@"propertyImgArr"];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error)
     {
         if(!error)
         {
             
             NSMutableArray *propertyListArr=[[NSMutableArray alloc] init];
             for (PFObject *pResult in result)
             {
                 PropertyList *property=[[PropertyList alloc] init];
                 NSLog(@"comment %@",pResult);
                 if ([pResult objectId].length!=0)
                 {
                     property.m_objectID=[pResult objectId];
                 }
                 if (pResult[@"amenities"] != [NSNull null])
                 {
                     property.m_amenities=pResult[@"amenities"];
                 }
                 if (pResult[@"building"] != [NSNull null])
                 {
                     property.m_building=pResult[@"building"];
                 }
                 if (pResult[@"city"] != [NSNull null])
                 {
                     property.m_city=pResult[@"city"];
                 }
                 if (pResult[@"description"] != [NSNull null])
                 {
                     property.m_description=pResult[@"description"];
                 }
                 if (pResult[@"houseNumber"] != [NSNull null])
                 {
                     property.m_houseNumber=pResult[@"houseNumber"];
                 }
                 if (pResult[@"latLong"] != [NSNull null])
                 {
                     property.m_latLong=pResult[@"latLong"];
                 }
                 if (pResult[@"numberOfBaths"] != [NSNull null])
                 {
                     property.m_numberOfBaths=pResult[@"numberOfBaths"];
                 }
                 if (pResult[@"numberOfBedrooms"] != [NSNull null])
                 {
                     property.m_numberOfBedrooms=pResult[@"numberOfBedrooms"];
                 }
                 if (pResult[@"postCode"] != [NSNull null])
                 {
                     property.m_postCode=pResult[@"postCode"];
                 }
                 if (pResult[@"nPropertySize"] != [NSNull null])
                 {
                     property.m_propertySize=pResult[@"nPropertySize"];
                 }
                 if (pResult[@"propertyType"] != [NSNull null])
                 {
                     property.m_propertyType=pResult[@"propertyType"];
                 }
                 if (pResult[@"street"] != [NSNull null])
                 {
                     property.m_street=pResult[@"street"];
                 }
                 if (pResult[@"unit"] != [NSNull null])
                 {
                     property.m_unit=pResult[@"unit"];
                 }
                 if (pResult[@"user"] != [NSNull null])
                 {
                     property.user=pResult[@"user"];
                 }
                 if (pResult[@"propertyImgArr"] != [NSNull null])
                 {
                     property.propertyImages=pResult[@"propertyImgArr"];
                 }
                 if (pResult[@"price"] != [NSNull null])
                 {
                     property.m_price=pResult[@"price"];
                 }
                 
                 [propertyListArr addObject:property];
             }
             
             [self reportSuccess:propertyListArr];
         }else
         {
             [self reportFailure:error];
         }
     }];
}
@end
