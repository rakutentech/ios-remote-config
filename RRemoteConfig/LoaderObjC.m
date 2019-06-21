#import <Foundation/Foundation.h>
#import <RRemoteConfig/RRemoteConfig-Swift.h>

@interface LoaderObjC : NSObject
@end

@implementation LoaderObjC : NSObject
+ (void)load {
    [Loader loadRemoteConfig];
}
@end
