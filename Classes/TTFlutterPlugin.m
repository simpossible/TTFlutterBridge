//
//  TTFlutterPlugin.m
//  TTFlutterBridge
//
//  Created by simp on 2020/11/12.
//

#import "TTFlutterPlugin.h"
#import "TTFlutterPluginOCBridge.h"
#import <objc/runtime.h>
#import "TTFlutterPluginRegistrant.h"

@interface TTFlutterPlugin()

@property (nonatomic, strong) TTFlutterPluginOCBridge * objcBridge;

@property (nonatomic, strong) NSObject<FlutterPluginRegistrar>* registrar;

@end

@implementation TTFlutterPlugin

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (self = [super init]) {
        self.registrar = registrar;
        self.objcBridge = [TTFlutterPluginOCBridge bridgeWithObject:self];
    }
    return self;;
}

/**初始化完成*/
- (void)oninitialOK {
    
}

+ (NSString *)flutterMethodName {
    return @"";
}

+ (NSString *)pluginKey {
    return @"";
}

+ (instancetype)getAPluginInstanceWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    return [[self alloc] initWithRegistrar:registrar];
}

- (instancetype)init {
    if (self = [super init]) {
        self.objcBridge = [TTFlutterPluginOCBridge bridgeWithObject:self];
    }
    return self;
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:[self flutterMethodName]
                                     binaryMessenger:[registrar messenger]];
    TTFlutterPlugin* instance = [self getAPluginInstanceWithRegistrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
    [instance oninitialOK];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self.objcBridge handleMethodCall:call result:result];
}

+ (void)registAllWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    [self loadAllPlugin:registry];
}

/**初始化加载组件*/
+ (void)loadAllPlugin:(NSObject<FlutterPluginRegistry>*)registry {
    Class class = [TTFlutterPlugin class];
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL,0);
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class currentCls = classes[i];
            if (class_getSuperclass(currentCls) == class){
                [currentCls registerWithRegistrar:[registry registrarForPlugin:[currentCls pluginKey]]];
            }
        }
        free(classes);
    }
}

@end
