//
//  Generated file. Do not edit.
//

#if __has_include(<FlutterPluginRegistrant/GeneratedPluginRegistrant.h>)
#import <FlutterPluginRegistrant/GeneratedPluginRegistrant.h>
#else
#if __has_include(<GeneratedPluginRegistrant.h>)
#import <GeneratedPluginRegistrant.h>
#else
#import "GeneratedPluginRegistrant.h"
#endif
#endif

@protocol TTGeneratedPluginRegistrantProtocol <NSObject>

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry;

@end

@interface GeneratedPluginRegistrant(TT)

@end

#import "TTFlutterPlugin.h"

#import <objc/message.h>

@implementation GeneratedPluginRegistrant(TT)


+ (void)load{
    Method method1 = class_getClassMethod([GeneratedPluginRegistrant class], @selector(registerWithRegistry:));
    Method method2 = class_getClassMethod([GeneratedPluginRegistrant class], @selector(ttRegisterWithRegistry:));
    method_exchangeImplementations(method1, method2);
}

+ (void)ttRegisterWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    [TTFlutterPlugin registAllWithRegistry:registry];
    [self ttRegisterWithRegistry:registry];
}


@end
