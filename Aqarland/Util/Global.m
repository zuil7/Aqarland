//
//  Global.m
//  
//
//

#import "Global.h"
#import "Constants.h"

@implementation Global

+ (Global*)sharedInstance
{
    static Global *sharedInstance; 
    static dispatch_once_t done; 
    dispatch_once(&done, ^{
        sharedInstance = [[Global alloc] init]; });
    return sharedInstance; 
}

// -------------------------------------------------------------------------
// Shows Alertview
// -------------------------------------------------------------------------
- (void) showAlert:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
                                                    message:message 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
	[alert show];
}

// -------------------------------------------------------------------------
// Desc	 : Reachability Impementation. Test for Internet Connection
// Return  : NO = no net connection; Yes = net connection available
// -------------------------------------------------------------------------
/*- (BOOL) checkInternetConnection
{
	Reachability *r = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL internet;

	if (internetStatus == NotReachable) internet = NO;
	else internet = YES;
	
	return internet;
}*/

// -------------------------------------------------------------------------
// Show the App Version
// -------------------------------------------------------------------------
- (NSString *) showAppVersion
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
	NSString *revision = [infoDictionary objectForKey:@"CFBundleVersion"];
	NSString *sReturn = [NSString stringWithFormat:@"Version %@ (rev %@)", version, revision];
	
	return sReturn;
}

// -------------------------------------------------------------------------
// Get the Device ID
// -------------------------------------------------------------------------
- (NSString *) getDeviceID
{
    NSString *sDeviceID = nil;
        
//#ifdef DEBUG_TEST_VARS
//    sDeviceID = DEBUG_TEST_DEVICE_ID;
//#else
//    sDeviceID = [[UIDevice currentDevice] uniqueIdentifier];
//#endif    
    
    // note: iOS 5+, uniqueIdentifier is deprecated.. warning!!!
    /*    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"5.0" options: NSNumericSearch];
     if (order == NSOrderedSame || order == NSOrderedDescending) {
     // OS version >= 5.0
     } else {
     // OS version < 5.0
     sDeviceID = [[UIDevice currentDevice] uniqueIdentifier];
     }
     */
    
    return sDeviceID;    
}

// -------------------------------------------------------------------------
// Encode a string to embed in an URL.
// -------------------------------------------------------------------------
- (NSString *) encodeToPercentEscapeString:(NSString *)string 
{    
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                     (__bridge CFStringRef) string,
                                                                     NULL,
                                                                     (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                     kCFStringEncodingUTF8));
}

// -------------------------------------------------------------------------
// Decode a percent escape encoded string.
// -------------------------------------------------------------------------
- (NSString *) decodeFromPercentEscapeString:(NSString *)string 
{    
    return CFBridgingRelease( CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, 
                                                                                      (__bridge CFStringRef) string,
                                                                                      CFSTR(""), 
                                                                                      kCFStringEncodingUTF8) );    
}

// -------------------------------------------------------------------------
// Private Method - Platform
// -------------------------------------------------------------------------
- (NSString *) platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

// -------------------------------------------------------------------------
// Platform String - get the device model
// -------------------------------------------------------------------------
- (NSString *) platformString
{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}
- (id) loadStoryBoardId:(NSString *) storyBoardID
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:storyBoardID];
}
#pragma mark - load plist 
+ (NSDictionary *)loadPlistfile:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

    return dict;
}

#pragma mark - load array with specific key
+ (NSArray *)loadPlistfile:(NSString *)name forKey:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *arraylist = [dict objectForKey:key];
    
    return arraylist;
}


#pragma mark - check numeric number 
+ (BOOL)isStringNumeric:(NSString *)aString
{
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithRange:NSMakeRange('0',10)] invertedSet];
    NSString *trimmed = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL isNumeric = trimmed.length > 0 && [trimmed rangeOfCharacterFromSet:nonNumberSet].location == NSNotFound;
    
    return isNumeric;
}

#pragma mark - separate string
+ (NSString *)separateString:(NSString *)str withOccuredString:(NSString *)kString
{
    NSString *finalString = [str stringByReplacingOccurrencesOfString:kString withString:@""];
    return finalString;
}

#pragma mark - group number with ','
+ (NSString *)formatString:(double)total withGroupSize:(int)size
{
    NSNumberFormatter *format = [[NSNumberFormatter alloc]init];
    [format setNumberStyle: NSNumberFormatterDecimalStyle];
    [format setGroupingSize:size];
    [format setGroupingSeparator:@","];
    [format setUsesGroupingSeparator: TRUE];
    NSString *result = [format stringFromNumber:[NSNumber numberWithDouble:total]];
    return result;
}

#pragma mark - convert string from Date
+ (NSString *)convertDateToString:(NSDate *)yourDate wantedFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *convertDateStr = [dateFormatter stringFromDate:yourDate];
    return convertDateStr;
}


+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
