//
//  AQAppDelegate.m
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQAppDelegate.h"
#import "HockeySDK.h"


@interface AQAppDelegate ()<BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>

@end

@implementation AQAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //*******************************************************************
    // Parse initialization
    [Parse setApplicationId:kParseID clientKey:kParseKey];
	// *****************************************************************
    
    
    [PFFacebookUtils initializeFacebook];
    
    [PFTwitterUtils initializeWithConsumerKey:kTwitterKey
                               consumerSecret:kTwitterSecret];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyKey delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
     [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     [[PFFacebookUtils session] close];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSLog(@"session %@",[PFFacebookUtils session]);

    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];

}

#pragma mark - BITUpdateManagerDelegate

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager
{
    return nil;
}


@end
