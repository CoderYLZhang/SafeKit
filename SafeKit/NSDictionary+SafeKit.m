//
//  NSDictionary+SafeKit.m
//  SafeKit
//
//  Created by 张银龙 on 2019/3/2.
//  Copyright © 2019 yinlong. All rights reserved.
//

#import "NSDictionary+SafeKit.h"
#import <objc/runtime.h>

@implementation NSDictionary (SafeKit)

+ (void)load {
    
    void (^swizzle)(Class, SEL, SEL, IMP, const char *) = ^(Class arrayClass,
                                                            SEL origin,
                                                            SEL override,
                                                            IMP overrideIMP,
                                                            const char *overrideEncode) {
        
        if (arrayClass == nil) {
            return;
        }
        
        Method origMethod = class_getInstanceMethod(arrayClass, origin);
        IMP originIMP = method_getImplementation(origMethod);
        //判断是否origin的函数指针是否和overrideIMP相同，如果相同则代表当调用origin方法的时候，实际上运行的是swizzled的代码，不需要再做swizz
        if (originIMP == overrideIMP) {
            return;
        }
        //针对当前类添加override实现(子类没有实现override方法)
        class_addMethod(arrayClass, override, overrideIMP, overrideEncode);
        if (class_addMethod(arrayClass, origin, overrideIMP, overrideEncode)) {
            //添加成功
            class_replaceMethod(arrayClass, override, originIMP, method_getTypeEncoding(origMethod));
        } else {
            //失败，表示方法本来就存在
            Method swizzleMethod = class_getInstanceMethod(arrayClass, override);
            method_exchangeImplementations(origMethod, swizzleMethod);
        }
    };
    
    // initWithObjects:
    Method initSwizzledMethod = class_getInstanceMethod(self, @selector(initWithObjects_safe:forKeys:count:));
    IMP safeInitMethod = method_getImplementation(initSwizzledMethod);
    const char *safeinitEncoding = method_getTypeEncoding(initSwizzledMethod);
    
    SEL initOriginalSEL = @selector(initWithObjects:forKeys:count:);
    SEL initSwizzledSEL = @selector(initWithObjects_safe:forKeys:count:);
    
    
    // setObject:forKey:
    Method setSwizzledMethod = class_getInstanceMethod(self, @selector(safe_setObject:forKey:));
    IMP safeSetMethod = method_getImplementation(setSwizzledMethod);
    const char *safeSetEncoding = method_getTypeEncoding(setSwizzledMethod);
    
    SEL setOriginalSEL = @selector(setObject:forKey:);
    SEL setSwizzledSEL = @selector(safe_setObject:forKey:);
    
    // setObject:forKeyedSubscript:
    Method setSubscriptSwizzledMethod = class_getInstanceMethod(self, @selector(safe_setObject:forKeyedSubscript:));
    IMP safeSetSubscriptMethod = method_getImplementation(setSubscriptSwizzledMethod);
    const char *safeSetSubscriptEncoding = method_getTypeEncoding(setSubscriptSwizzledMethod);
    
    SEL setSubscriptOriginalSEL = @selector(setObject:forKeyedSubscript:);
    SEL setSubscriptSwizzledSEL = @selector(safe_setObject:forKeyedSubscript:);
    
    
    // removeObjectForKey:
    Method removeSwizzledMethod = class_getInstanceMethod(self, @selector(safe_removeObjectForKey:));
    IMP safeRemoveMethod = method_getImplementation(removeSwizzledMethod);
    const char *safeRemoveEncoding = method_getTypeEncoding(removeSwizzledMethod);
    
    SEL removeOriginalSEL = @selector(removeObjectForKey:);
    SEL removeSwizzledSEL = @selector(safe_removeObjectForKey:);
    
    NSArray *classNames = @[@"NSDictionary", @"__NSDictionaryM", @"__NSPlaceholderDictionary"];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        for (NSString *className in classNames) {
            
            Class aClass = NSClassFromString(className);
            
            swizzle(aClass, initOriginalSEL, initSwizzledSEL, safeInitMethod, safeinitEncoding);
            swizzle(aClass, setOriginalSEL, setSwizzledSEL, safeSetMethod, safeSetEncoding);
            swizzle(aClass, setSubscriptOriginalSEL, setSubscriptSwizzledSEL, safeSetSubscriptMethod, safeSetSubscriptEncoding);
            swizzle(aClass, removeOriginalSEL, removeSwizzledSEL, safeRemoveMethod, safeRemoveEncoding);
        }
    });
}

- (instancetype)initWithObjects_safe:(id *)objects
                        forKeys:(id<NSCopying> *)keys
                          count:(NSUInteger)cnt {
    NSUInteger newCnt = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        if (!(keys[i] && objects[i])) {
            break;
        }
        newCnt++;
    }
    self = [self initWithObjects_safe:objects forKeys:keys count:newCnt];
    return self;
}

- (void)safe_setObject:(id)value forKey:(NSString *)key {
    if (value && key) {
        [self safe_setObject:value forKey:key];
    }
}

- (void)safe_setObject:(id)value forKeyedSubscript:(NSString *)key {
    if (key) {
        [self safe_setObject:value forKeyedSubscript:key];
    }
}

- (void)safe_removeObjectForKey:(id)aKey {
    if (aKey) {
        [self safe_removeObjectForKey:aKey];
    }
}


@end
