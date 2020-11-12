//
//  TTFlutterOcMethod.h
//  NativeString
//
//  Created by simp on 2020/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTFlutterOcMethod : NSObject

@property (nonatomic) SEL selector;

@property (nonatomic, assign) NSInteger argCount;

/**是否是同步接口*/
@property (nonatomic, assign) BOOL async;


- (instancetype)initWith:(SEL)selector argCount:(NSInteger)count isAsync:(BOOL)async;
@end


NS_ASSUME_NONNULL_END
