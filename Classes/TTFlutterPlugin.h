//
//  TTFlutterPlugin.h
//  TTFlutterBridge
//
//  Created by simp on 2020/11/12.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN


/// TT的Flutter插件的公共类 继承直接使用
@interface TTFlutterPlugin : NSObject<FlutterPlugin>

@property (nonatomic, strong, readonly) NSObject<FlutterPluginRegistrar>* registrar;

+ (void)registAllWithRegistry:(NSObject<FlutterPluginRegistry>*)registry;

/**初始化完成*/
- (void)oninitialOK;

@end

NS_ASSUME_NONNULL_END
