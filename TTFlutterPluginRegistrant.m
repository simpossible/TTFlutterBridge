//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <TTFlutterBridge/TTFlutterPlugin.h>


@implementation GeneratedPluginRegistrant(TT)


+ (void)load{
    Method method1 = class_getClassMethod([GeneratedPluginRegistrant class], @selector(registerWithRegistry:));
    Method method2 = class_getClassMethod([GeneratedPluginRegistrant class], @selector(ttRegisterWithRegistry:));
    method_exchangeImplementations(method1, method2);
}

+ (void)ttRegisterWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    [TTFlutterPlugin registAllWithRegistry:registry];
    [self.ttRegisterWithRegistry:registry];
}


@end
