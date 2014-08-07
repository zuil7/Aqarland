//
//  Constants.h
//  Aqarland
//
//  Created by Louise on 28/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#ifndef Aqarland_Constants_h
#define Aqarland_Constants_h

// AppId,Keys,Secret

#define kParseID         @"cvodd4wBbMDqNqp8khttOc1Zqvtn31DxBoV60BHt"
#define kParseKey        @"SaZxQNxOgCy86NL897ke7qVepD83983RfsnSwu3T"

#define kTwitterKey        @"ON6HNap5oeszraBIbqKTaj8Ir"
#define kTwitterSecret        @"JGmXOakwYP6dYJV6gzRUsOGy7X2m2JHldmpgZQsrU8qTlNLfo1"



//App delegate Easy ACCESS
#define APP_DELEGATE (AQAppDelegate *)[[UIApplication sharedApplication] delegate]
//main VC
#define ROOT_VC [APP_DELEGATE viewController]

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define GlobalInstance [Global sharedInstance]

//Standard Text
#define iErrorInfo      @"Error Message"

//Header Bar
#define TitleHeaderFont @"Helvetica"

//StoryBoard ID
#define sSideMenuVC         @"SideMenuVC"
#define sHomeVC             @"HomeVC"
#define sSignUpVC           @"SignUpVC"
#define sCreateAccountVC    @"CreateAccountVC"

//Parse Class Name
#define pUser               @"User"
#define pUserProfile        @"UserProfile"


#endif
