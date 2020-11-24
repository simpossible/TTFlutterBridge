//
//  TTFlutterPluginOCBridge.h
//  NativeString
//
//  Created by simp on 2020/11/11.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTFlutterPluginOCBridge : NSObject

+ (instancetype)bridgeWithObject:(NSObject *)obj;

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
