//
//  TTFlutterOcMethod.m
//  NativeString
//
//  Created by simp on 2020/11/11.
//

#import "TTFlutterOcMethod.h"

NSString * const TTFlutterOcArgFirstTag = @"With";
NSString * const TTFlutterOcArgTag = @"with";

@interface TTFlutterOcMethod()

/**存储所有参数的前缀*/
@property (nonatomic, strong) NSArray * allArgKey;

@property (nonatomic, assign) TTFlutterOcMethodType type;

/**第一部分的名字-key值*/
@property (nonatomic, copy) NSString * firstPart;

@property (nonatomic) SEL selector;

/**参数总个数*/
@property (nonatomic, assign) NSInteger argCount;

/**是否是同步接口*/
@property (nonatomic, assign) BOOL async;

@end

BOOL TTIsTypeQualifier(char c)
{
    if (c == 'r' || c == 'n' || c == 'N' || c == 'o' || c == 'O' || c == 'R' || c == 'V') {
        return YES;
    }
    return NO;
}

@implementation TTFlutterOcMethod

+ (instancetype)initWithSEL:(SEL)selector {
    NSString *name = NSStringFromSelector(selector);
    if ([name hasPrefix:@"dart"]) {
        return  [self argsMeghodWithName:name sel:selector];
    }else if ([name hasPrefix:@"_dart"]) {
        return  [self orgMeghodWithName:name sel:selector];
    }
    return nil;
}

/**需要整个参数的*/
+ (instancetype)orgMeghodWithName:(NSString *)name sel:(SEL)selector {
    TTFlutterOcMethod *m = [[TTFlutterOcMethod alloc] init];
    m.selector = selector;
    m.type = TTFlutterOcMethodTypeOrigin;
    BOOL async = [name hasPrefix:@"_dartAsync"];//是否是异步返回
    m.async = async;
    NSInteger argsCount = [self numberOfArgsForMehodName:name];//这个函数的参数个数
    if (argsCount == 0 && async) {//不支持没有参数的异步函数
        return nil;
    }
    m.argCount = argsCount;
    
    NSArray * allCompos = [name componentsSeparatedByString:@":"];//解析出来所有的函数部分
    NSString * firstPart = allCompos[0];//第一部分
    if (async) {
        firstPart = [firstPart substringFromIndex:10];//记录真正的dart_key值
    }else {
        firstPart = [firstPart substringFromIndex:5];//记录真正的dart_key值
    }
    
    NSRange firstPargRange = [firstPart rangeOfString:TTFlutterOcArgFirstTag];
    if (firstPargRange.location != NSNotFound) {
        m.firstPart = [firstPart substringToIndex:firstPargRange.location];
    }else {
        m.firstPart = firstPart;
    }
    
    NSMutableArray * allArgKeys = [NSMutableArray array];
    if (argsCount != 0) {//如果参数个数不等于0 //处理所有的参数对应的key 给字典类型的参数使用
        for (int i = 0; i < argsCount; i ++) {
            if (async) {
                if (i != 0) {
                    NSString * argPrefix = [allCompos objectAtIndex:i-1];
                    NSRange range = [argPrefix rangeOfString:TTFlutterOcArgTag];//找到是否有with 前缀
                    if (range.location != NSNotFound) {
                        argPrefix = [argPrefix substringFromIndex:(range.location + range.length)];//找到真正的前缀
                        [allArgKeys addObject:argPrefix];
                    }
                }
            }else {
                NSString * argPrefix = i == 0 ? firstPart : allCompos[i];
                NSString * withString = TTFlutterOcArgTag;
                if (i == 0) {
                    withString = TTFlutterOcArgFirstTag;
                }
                NSRange range = [argPrefix rangeOfString:withString];//找到是否有with 前缀
                if (range.location != NSNotFound) {
                    argPrefix = [argPrefix substringFromIndex:(range.location + range.length)];//找到真正的前缀
                    [allArgKeys addObject:argPrefix];
                }
            }
            
        }
    }
    if (allArgKeys.count != 0) {
        m.allArgKey = allArgKeys;
    }
    
    return m;
}

+ (instancetype)argsMeghodWithName:(NSString *)name sel:(SEL)selector {
    TTFlutterOcMethod *m = [[TTFlutterOcMethod alloc] init];
    m.selector = selector;
    m.type = TTFlutterOcMethodTypeArgs;
    BOOL async = [name hasPrefix:@"dartAsync"];//是否是异步返回
    m.async = async;
    NSInteger argsCount = [self numberOfArgsForMehodName:name];//这个函数的参数个数
    if (argsCount == 0 && async) {//不支持没有参数的异步函数
        return nil;
    }
    m.argCount = argsCount;
    NSArray * allCompos = [name componentsSeparatedByString:@":"];//解析出来所有的函数部分
    NSString * firstPart = allCompos[0];//第一部分
    if (async) {
        firstPart = [firstPart substringFromIndex:9];//记录真正的dart_key值
    }else {
        firstPart = [firstPart substringFromIndex:4];//记录真正的dart_key值
    }
    
    NSRange firstPargRange = [firstPart rangeOfString:TTFlutterOcArgFirstTag];
    if (firstPargRange.location != NSNotFound) {
        m.firstPart = [firstPart substringToIndex:firstPargRange.location];
    }else {
        m.firstPart = firstPart;
    }
    
    NSMutableArray * allArgKeys = [NSMutableArray array];
    if (argsCount != 0) {//如果参数个数不等于0 //处理所有的参数对应的key 给字典类型的参数使用
        for (int i = 0; i < argsCount; i ++) {
            if (async) {
                if (i != 0) {
                    NSString * argPrefix = [allCompos objectAtIndex:i];
                    NSRange range = [argPrefix rangeOfString:TTFlutterOcArgTag];//找到是否有with 前缀
                    if (range.location != NSNotFound) {
                        argPrefix = [argPrefix substringFromIndex:(range.location + range.length)];//找到真正的前缀
                        [allArgKeys addObject:argPrefix];
                    }else {
                        [allArgKeys addObject:argPrefix];
                    }
                }
            }else {
                NSString * argPrefix = i == 0 ? firstPart : allCompos[i];
                NSRange range = [argPrefix rangeOfString:TTFlutterOcArgTag];//找到是否有with 前缀
                if (range.location != NSNotFound) {
                    argPrefix = [argPrefix substringFromIndex:(range.location + range.length)];//找到真正的前缀
                    [allArgKeys addObject:argPrefix];
                }else {
                    [allArgKeys addObject:argPrefix];
                }
            }
            
        }
    }
    if (allArgKeys.count != 0) {
        m.allArgKey = allArgKeys;
    }
    
    return m;
}

- (NSInteger)inputArgCount {
    return _async ? _argCount - 1 :_argCount;
}

- (instancetype)initWith:(SEL)selector argCount:(NSInteger)count isAsync:(BOOL)async {
    if (self = [super init]) {
        self.selector = selector;
        self.argCount = count;
        self.async = async;
    }
    return self;
}

+ (NSInteger)numberOfArgsForMehodName:(NSString *)name {
    NSInteger count = [[name mutableCopy] replaceOccurrencesOfString:@":" // 要查询的字符串中的某个字符
                                                          withString:@"C"
                                                             options:NSLiteralSearch
                                                               range:NSMakeRange(0, [name length])];
    return count;
}

/**不带参数*/
- (void)excuteNoArgWithObj:(NSObject *)obj call:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSMethodSignature *signature = [[obj class] instanceMethodSignatureForSelector:_selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSUInteger argsCount = signature.numberOfArguments - 2; //本来的参数个数
    invocation.target = obj;
    invocation.selector = _selector;
    // 设置参数
    if (_async) {
        if (argsCount == 0) {
            result(nil);
            NSLog(@"异步接口未定义返回值");
            return;
        }
        [invocation setArgument:&result atIndex:2];
        // 调用方法
        [invocation invoke];
    }else {
        // 调用方法
        [invocation invoke];
        NSObject * __unsafe_unretained returnArgument = nil;
        if (signature.methodReturnLength) {
            [invocation getReturnValue:&returnArgument];
        }
        NSObject *returnValue = returnArgument;
        result(returnValue);
    }
}


/**当参数是一个字典的时候*/
- (void)excuteDicArgWithObj:(NSObject *)obj param:(NSDictionary *)param call:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSMethodSignature *signature = [[obj class] instanceMethodSignatureForSelector:_selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSUInteger argsCount = signature.numberOfArguments - 2; //本来的参数个数
    NSUInteger paramCount = param.count; //收到的参数个数
    invocation.target = obj;
    invocation.selector = _selector;
    // 设置参数
    if (_async) {
        if (argsCount == 0) {
            result(nil);
            NSLog(@"异步接口未定义返回值");
            return;
        }
        argsCount --;
        [invocation setArgument:&result atIndex:2];
        for (int i = 0; i < argsCount; i ++) {
            if (i < paramCount) {
                NSString *key = _allArgKey[i];//拿到key 这里默认是有值的
                NSObject *arg = param[key];
                NSInteger index = i + 3;
                [self invoke:invocation arg:arg index:index];
            }else {
                break;
            }
        }
        // 调用方法
        [invocation invoke];
    }else {
        for (int i = 0; i < argsCount; i ++) {
            if (i < paramCount) {
                NSString *key = _allArgKey[i];//拿到key 这里默认是有值的
                NSObject *arg = param[key];
                NSInteger index = i + 2;
                [self invoke:invocation arg:arg index:index];
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
}

- (void)excuteArrArgWithObj:(NSObject *)obj param:(NSArray *)param call:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSMethodSignature *signature = [[obj class] instanceMethodSignatureForSelector:_selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSUInteger argsCount = signature.numberOfArguments - 2; //本来的参数个数
    NSUInteger paramCount = param.count; //收到的参数个数
    invocation.target = obj;
    invocation.selector = _selector;
    // 设置参数
    if (_async) {
        if (argsCount == 0) {
            result(nil);
            NSLog(@"异步接口未定义返回值");
            return;
        }
        argsCount --;
        [invocation setArgument:&result atIndex:2];
        for (int i = 0; i < argsCount; i ++) {
            if (i < paramCount) {
                NSObject *arg = param[i];
                NSInteger index = i + 3;
                [self invoke:invocation arg:arg index:index];
            }else {
                break;
            }
        }
        // 调用方法
        [invocation invoke];
    }else {
        for (int i = 0; i < argsCount; i ++) {
            if (i < paramCount) {
                NSObject *arg = param[i];
                NSInteger index = i + 2;
                [self invoke:invocation arg:arg index:index];
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
}


- (void)excuteOrgMethodWithObj:(NSObject *)obj call:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSObject * param = call.arguments;
    NSMethodSignature *signature = [[obj class] instanceMethodSignatureForSelector:_selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSUInteger argsCount = signature.numberOfArguments - 2; //本来的参数个数
    invocation.target = obj;
    invocation.selector = _selector;
    // 设置参数
    if (_async) {
        if (argsCount == 0) {
            result(nil);
            NSLog(@"异步接口未定义返回值");
            return;
        }
        argsCount --;
        [invocation setArgument:&result atIndex:2];
        if (param) {
            [invocation setArgument:&param atIndex:3];
        }
        // 调用方法
        [invocation invoke];
    }else {
        if (param) {
            [invocation setArgument:&param atIndex:2];
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
}



- (void)invoke:(NSInvocation *)invocation arg:(id)arg index:(int)index {
    const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    switch (TTIsTypeQualifier(argumentType[0]) ? argumentType[1] : argumentType[0]) {
#define MT_FWD_ARG_CASE(_typeChar, _type, _typeCapitalizedString) \
case _typeChar: {   \
NSNumber *number = arg; \
_type value = [number _typeCapitalizedString##Value]; \
[invocation setArgument:&value atIndex:index];  \
break;  \
}
            MT_FWD_ARG_CASE('i', int, int)
            MT_FWD_ARG_CASE('s', short, short)
            MT_FWD_ARG_CASE('l', long, long)
            MT_FWD_ARG_CASE('q', long long, longLong)
            MT_FWD_ARG_CASE('C', unsigned char, unsignedChar)
            MT_FWD_ARG_CASE('I', unsigned int, unsignedInt)
            MT_FWD_ARG_CASE('S', unsigned short, unsignedShort)
            MT_FWD_ARG_CASE('L', unsigned long, unsignedLong)
            MT_FWD_ARG_CASE('Q', unsigned long long, unsignedLongLong)
            MT_FWD_ARG_CASE('f', float, float)
            MT_FWD_ARG_CASE('d', double, double)
            MT_FWD_ARG_CASE('B', BOOL, bool)
        case 'c':{
            NSString *str = arg;
            const char *c = [str UTF8String];
            [invocation setArgument:&c atIndex:index];
            break;
        }

        default:
            [invocation setArgument:&arg atIndex:index];
            break;
    }
    
}


@end
