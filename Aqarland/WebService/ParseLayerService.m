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


#define mSuccess [NSNumber numberWithBool:1]
#define mFailed  [NSNumber numberWithBool:0]

#define sTwitterURL @"https://api.twitter.com/1.1/users/show.json?screen_name=%@"

static ParseLayerService *instance = nil;

@implementation ParseLayerService

{
    AQResultBlock completionBlock;
    AQFailedBlock failureBlock;
}

+ (ParseLayerService *) sharedInstance
{
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
            [self reportSuccess:[NSNumber numberWithBool:succeeded]];
        }
        else
        {
            [self reportFailure:error];
        }
    }];
}
/*
-(void) updateUserEmailViaFB:(NSDictionary *) profileInfo
{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFUser query];
   
    NSLog(@"currentUser %@",currentUser.objectId);
    
    
// Retrieve the object by id
    [query getObjectInBackgroundWithId:currentUser.objectId block:^(PFObject *gameScore, NSError *error)
    {
        NSLog(@"error %@",error);
    // Now let's update it with some new data. In this case, only cheatMode and score
    // will get sent to the cloud. playerName hasn't changed.
    gameScore[@"email"] = profileInfo[@"email"];
    
        [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
            if (succeeded)
            {
                [self createAccountViaFB:profileInfo];
            }
            else
            {
                [self reportFailure:error];
            }
        }];
    
    }];
}*/
////////////////////////////////
// Create Account Via FB
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
                          NSLog(@"pUserProfile %d",[result count]);
                          if([result count]==0)
                          {
                              PFObject *post = [PFObject objectWithClassName:pUserProfile];
                              post[@"user"] = user;
                              post[@"fullName"] = resultDict[@"name"];
                              
                              NSString *cleanProfileImageURL=[resultDict[@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
                              NSLog(@"cleanProfileImageURL %@",cleanProfileImageURL);
                              NSURL *pictureURL = [NSURL URLWithString:cleanProfileImageURL];
                              NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                              PFFile *imageFile = [PFFile fileWithData:imageData];
                              [post setObject:imageFile forKey:@"userAvatar"];
                              [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                               {
                                   if (!error)
                                   {
                                       PFUser *user=[PFUser currentUser];
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

- (void) requestLogin:(NSString *)username passWord:(NSString *) pass;
{
    [PFUser logInWithUsernameInBackground:username password:pass
                                    block:^(PFUser *user, NSError *error)
     {
         NSLog(@"user %@",user);
        if (user)
        {
            [self reportSuccess:user];
        } else
        {
            [self reportFailure:error];
        }
    }];
}
@end
