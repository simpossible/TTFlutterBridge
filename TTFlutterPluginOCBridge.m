//
//  TTFlutterPluginOCBridge.m
//  NativeString
//
//  Created by simp on 2020/11/11.
//

#import "TTFlutterPluginOCBridge.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TTFlutterOcMethod.h"

@interface TTFlutterPluginOCBridge()

@property (nonatomic, strong) NSObject * obj;

/**固定参数个数的方法*/
@property (nonatomic, strong) NSDictionary * allFixMethods;

/**所有的方法*/
@property (nonatomic, strong) NSDictionary * allMethods;

@end

@implementation TTFlutterPluginOCBridge

- (instancetype)initWithObj:(NSObject *)obj {
    if (self = [super init]) {
        self.obj = obj;
        unsigned int count;
        Method *methods = class_copyMethodList([obj class], &count);
        NSMutableDictionary * fixMethods = [NSMutableDictionary dictionary];
        NSMutableDictionary * allMethods = [NSMutableDictionary dictionary];
        for (int i = 0; i < count; i++)
        {
            Method method = methods[i];
            SEL selector = method_getName(method);
            NSString *name = NSStringFromSelector(selector);
            
            if ([name hasPrefix:@"dart"]) {//所有支持dart的方法
                BOOL async = [name hasPrefix:@"dartAsync"];
                NSInteger paramCount = [self numberOfParasForMehodName:name];//找到有几个参数
                NSString * firstPart = name;
                if (paramCount>0) {
                    NSArray *components = [name componentsSeparatedByString:@":"];
                    firstPart = components.firstObject;
                }
                
                if (async) {
                    firstPart = [firstPart substringFromIndex:9];//记录真正的dart_key值
                }else {
                    firstPart = [firstPart substringFromIndex:9];//记录真正的dart_key值
                }
                firstPart = [firstPart lowercaseString];
                
                //如果是异步 那么有效参数减少1个
                NSInteger validParamCount = async ? paramCount - 1 : paramCount;
                TTFlutterOcMethod * m = [[TTFlutterOcMethod alloc] initWith:selector argCount:validParamCount isAsync:async];
                
                NSString *key = [NSString stringWithFormat:@"%@_%@",firstPart,@(validParamCount)];
                fixMethods[key] = m;
                
                NSMutableArray *methodsList = allMethods[firstPart];
                if (!methodsList) {
                    methodsList = [NSMutableArray array];
                    allMethods[firstPart] = methodsList;
                }
                [methodsList addObject:m];
            }
        }
        self.allFixMethods = fixMethods;
        self.allMethods = allMethods;
    }
    return self;
}

- (NSInteger)numberOfParasForMehodName:(NSString *)name {
    NSInteger count = [[name mutableCopy] replaceOccurrencesOfString:@":" // 要查询的字符串中的某个字符
                                                          withString:@"C"
                                                             options:NSLiteralSearch
                                                               range:NSMakeRange(0, [name length])];
    return count;
}

+ (instancetype)bridgeWithObject:(NSObject *)obj {
    return [[TTFlutterPluginOCBridge alloc] initWithObj:obj];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *method = call.method;
    NSArray * parameters = call.arguments;
    
    NSString * methodname;
    NSInteger paramDefingCount = parameters.count;
//    if ([method hasPrefix:@"async"]) {
//        NSString *realM = [method substringFromIndex:5];
//        paramDefingCount += 1;
//        methodname = [NSString stringWithFormat:@"dartAsync%@",[realM capitalizedString]];;
//    }else {
//        methodname = [NSString stringWithFormat:@"dart%@",[method capitalizedString]];
//    }
     

    TTFlutterOcMethod * m = [self ocMethodWithName:method count:paramDefingCount];
        
    if (m) {
        NSMethodSignature *signature = [[self.obj class] instanceMethodSignatureForSelector:m.selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        NSUInteger argsCount = signature.numberOfArguments - 2; //本来的参数个数
        NSUInteger arrCount = parameters.count; //收到的参数个数
        
        invocation.target = self.obj;
        invocation.selector = m.selector;
        // 设置参数
        if (m.async) {
            if (argsCount == 0) {
                result(nil);
                NSLog(@"异步接口未定义返回值");
                return;
            }
            argsCount --;
            [invocation setArgument:&result atIndex:2];
            for (int i = 0; i < argsCount; i ++) {
                if (i < arrCount) {
                    NSObject *arg = parameters[i];
                    NSInteger index = i + 3;
                    [invocation setArgument:&arg atIndex:index];
                }else {
                    break;
                }
            }
            // 调用方法
            [invocation invoke];
        }else {
            for (int i = 0; i < argsCount; i ++) {
                if (i < arrCount) {
                    NSObject *arg = parameters[i];
                    NSInteger index = i + 2;
                    [invocation setArgument:&arg atIndex:index];
                }else {
                    break;
                }
            }
            // 调用方法
            [invocation invoke];
            NSObject * __unsafe_unretained returnArgument = nil;
            if (signature.methodReturnLength) {
                [invocation getReturnValue:&returnArgument];
            }
            NSObject *returnValue = returnArgument;
            result(returnValue);
        }
       
    }else {
        result(FlutterMethodNotImplemented);
    }
}


- (TTFlutterOcMethod *)ocMethodWithName:(NSString *)name count:(NSInteger)paramCount {
    name = [name lowercaseString];
    TTFlutterOcMethod *m = self.allFixMethods[[NSString stringWithFormat:@"%@_%d",name,paramCount]];
    if (!m) {
        NSArray * allMehohds = self.allMethods[name];
        if (allMehohds) {
            NSInteger paramOff = -100;//参数个数的差异
            for (TTFlutterOcMethod *ocMethod in allMehohds) {
                NSInteger currentParamOff = paramCount - ocMethod.argCount;
                if (currentParamOff >= 0) {//尽量取实际参数大于定义参数的情况
                    if (paramOff < 0) {
                        paramOff = currentParamOff;
                        m = ocMethod;
                    }else {
                        if (currentParamOff < paramOff) {
                            paramOff = currentParamOff;
                            m = ocMethod;
                        }
                    }
                    
                }else {
                    if (paramOff < 0) {
                        if (currentParamOff > paramOff) {
                            paramOff = currentParamOff;
                            m = ocMethod;
                        }
                    }else {
                      
                    }
                }
            }
        }
    }
    return m;
}


@end

