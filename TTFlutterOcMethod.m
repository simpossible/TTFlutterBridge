//
//  TTFlutterOcMethod.m
//  NativeString
//
//  Created by simp on 2020/11/11.
//

#import "TTFlutterOcMethod.h"



@implementation TTFlutterOcMethod

- (instancetype)initWith:(SEL)selector argCount:(NSInteger)count isAsync:(BOOL)async {
    if (self = [super init]) {
        self.selector = selector;
        self.argCount = count;
        self.async = async;
    }
    return self;
}

@end
