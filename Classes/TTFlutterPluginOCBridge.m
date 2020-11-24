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

/**所有接受原始参数的方法*/
@property (nonatomic, strong) NSDictionary * allOriginMethod;

@end

@implementation TTFlutterPluginOCBridge

- (instancetype)initWithObj:(NSObject *)obj {
    if (self = [super init]) {
        self.obj = obj;
        unsigned int count;
        Method *methods = class_copyMethodList([obj class], &count);
        
        NSMutableDictionary * originMethodDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * argMethodsFix = [NSMutableDictionary dictionary];// 根据参数个数接受参数
        NSMutableDictionary * allMethods = [NSMutableDictionary dictionary];//记录所有的函数
        
        for (int i = 0; i < count; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            
            TTFlutterOcMethod *m = [TTFlutterOcMethod initWithSEL:selector];
            if (m) {
                NSString * firstPartKey = [m.firstPart lowercaseString];
                NSMutableArray *array = [allMethods objectForKey:firstPartKey];
                if (!array) {
                    array = [NSMutableArray array];
                    allMethods[m.firstPart] = array;
                }
                [array addObject:m];
                if (m.type == TTFlutterOcMethodTypeOrigin) {
                    [originMethodDic setObject:m forKey:firstPartKey];
                }else {
                    [argMethodsFix setObject:m forKey:[NSString stringWithFormat:@"%@_%ld",firstPartKey,(long)m.inputArgCount]];
                }
            }
        }
        self.allFixMethods = argMethodsFix;
        self.allMethods = allMethods;
        self.allOriginMethod = originMethodDic;
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
    
    //    if ([method hasPrefix:@"async"]) {
    //        NSString *realM = [method substringFromIndex:5];
    //        paramDefingCount += 1;
    //        methodname = [NSString stringWithFormat:@"dartAsync%@",[realM capitalizedString]];;
    //    }else {
    //        methodname = [NSString stringWithFormat:@"dart%@",[method capitalizedString]];
    //    }
    
//    TTFlutterOcMethod * m = [self ocMethodWithName:method count:paramDefingCount];
    
    NSString * name = [method lowercaseString];
    TTFlutterOcMethod * m = [self.allOriginMethod objectForKey:name];
    
    if (m) {//如果有定义一个 _dart 的接口 那么优先使用这个接口
        [m excuteOrgMethodWithObj:_obj call:call result:result];
    }else {
        if (parameters) {//如果有参数
            NSInteger paramesCount = 1;
            
            if ([parameters isKindOfClass:NSArray.class]){
                m = [self ocMethodWithName:name count:parameters.count];
                [m excuteArrArgWithObj:_obj param:parameters call:call result:result];
            }else if([parameters isKindOfClass:[NSDictionary class]]) {
                m = [self ocMethodWithName:name count:parameters.count];
                [m excuteDicArgWithObj:_obj param:parameters call:call result:result];
            }else {
                m = [self ocMethodWithName:name count:1];
                [m excuteArrArgWithObj:_obj param:@[parameters] call:call result:result];
            }
                        
        }else {
            m = [self ocMethodWithName:name count:0];
            [m excuteNoArgWithObj:_obj call:call result:result];
        }
       
    }
    if (!m) {
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


