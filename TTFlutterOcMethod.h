//
//  TTFlutterOcMethod.h
//  NativeString
//
//  Created by simp on 2020/11/11.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, TTFlutterOcMethodType) {
    TTFlutterOcMethodTypeArgs,//参数分开导入 dart 开头
    TTFlutterOcMethodTypeOrigin,//直接需要原始参数 _dart 开头
};

@interface TTFlutterOcMethod : NSObject

/**
 * 全匹配的名字 a:b: -> a_b_
 * 当参数是字典的时候进行匹配
 */
@property (nonatomic, copy) NSString * fullMatchKey;

@property (nonatomic, assign, readonly) TTFlutterOcMethodType type;

/**第一部分的名字-key值*/
@property (nonatomic, copy, readonly) NSString * firstPart;

@property (nonatomic, readonly) SEL selector;

/**参数总个数*/
@property (nonatomic, assign, readonly) NSInteger argCount;

/**接受参数的个数*/
@property (nonatomic, assign, readonly) NSInteger inputArgCount;

/**是否是同步接口*/
@property (nonatomic, assign, readonly) BOOL async;


/**
 * 第一部分的名字 a:() b:() -> a
 * 这个当时数组参数的时候可以直接匹配
 */

+ (instancetype)initWithSEL:(SEL)selector;

/**不带参数*/
- (void)excuteNoArgWithObj:(NSObject *)obj call:(FlutterMethodCall*)call result:(FlutterResult)result;


- (void)excuteDicArgWithObj:(NSObject *)obj param:(NSDictionary *)param call:(FlutterMethodCall*)call result:(FlutterResult)result;

- (void)excuteArrArgWithObj:(NSObject *)obj param:(NSArray *)param call:(FlutterMethodCall*)call result:(FlutterResult)result;


- (void)excuteOrgMethodWithObj:(NSObject *)obj call:(FlutterMethodCall*)call result:(FlutterResult)result;

@end


NS_ASSUME_NONNULL_END
