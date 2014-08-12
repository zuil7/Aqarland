//
//  Global.h
//  
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>


//----------------------------------------------------------------------
// Global - Singleton Class consists of Factory Methods
//----------------------------------------------------------------------
@interface Global : NSObject

@property(strong,nonatomic) UINavigationController *navController;

+ (Global*)sharedInstance;

- (id) loadStoryBoardId:(NSString *) storyBoardID;
- (void) showAlert:(NSString *)title message:(NSString *)message;
- (NSString *) showAppVersion;
- (NSString *) getDeviceID;
- (NSString *) encodeToPercentEscapeString:(NSString *)string;
- (NSString *) decodeFromPercentEscapeString:(NSString *)string;
- (NSString *) platformString;
- (NSArray *) loadPlistfile:(NSString *)name forKey:(NSString *)key;

+ (BOOL)isStringNumeric:(NSString *)aString;
+ (NSString *)separateString:(NSString *)str withOccuredString:(NSString *)kString;
+ (NSString *)formatString:(double)total withGroupSize:(int)size;
+ (NSString *)convertDateToString:(NSDate *)yourDate wantedFormat:(NSString *)format;
+ (NSDictionary *)loadPlistfile:(NSString *)name;

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;


@end
