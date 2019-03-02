//
//  NSArray+SafeKit.m
//  SafeKit
//
//  Created by 张银龙 on 2019/3/1.
//  Copyright © 2019 yinlong. All rights reserved.
//

#import "NSArray+SafeKit.h"
#import <objc/runtime.h>

@implementation NSArray (SafeKit)

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
    
    // objectAtIndex:
    Method arraySwizzledMethod = class_getInstanceMethod(self, @selector(safe_objectAtIndex:));
    IMP safeIndexMethod = method_getImplementation(arraySwizzledMethod);
    const char *safeIndexEncoding = method_getTypeEncoding(arraySwizzledMethod);
    
    SEL originalSEL = @selector(objectAtIndex:);
    SEL swizzledSEL = @selector(safe_objectAtIndex:);
    
    // objectAtIndexedSubscript:
    Method arraySubscriptMethod = class_getInstanceMethod(self, @selector(safe_objectAtIndexedSubscript:));
    IMP safeIndexSubscriptIMP = method_getImplementation(arraySubscriptMethod);
    const char *safeIndexSubscriptEncoding = method_getTypeEncoding(arraySubscriptMethod);
    
    SEL originalSubscriptSEL = @selector(objectAtIndexedSubscript:);
    SEL swizzledSubscriptSEL = @selector(safe_objectAtIndexedSubscript:);
    
    // initWithObjects:count:
    Method arrayInitMethod = class_getInstanceMethod(self, @selector(initWithObjects_safe:count:));
    IMP safeArrayInitIMP = method_getImplementation(arrayInitMethod);
    const char *safeArrayInitEncoding = method_getTypeEncoding(arrayInitMethod);
    
    SEL originalInitSEL = @selector(initWithObjects:count:);
    SEL swizzledInitSEL = @selector(initWithObjects_safe:count:);
    
    // arrayByAddingObject
    Method arrayAddingMethod = class_getInstanceMethod(self, @selector(safe_arrayByAddingObject:));
    IMP safeArrayAddingIMP = method_getImplementation(arrayAddingMethod);
    const char *safeArrayAddingEncoding = method_getTypeEncoding(arrayAddingMethod);
    
    SEL originalAddingSEL = @selector(arrayByAddingObject:);
    SEL swizzledAddingSEL = @selector(safe_arrayByAddingObject:);
    
    
    // addObject
    Method arrayAddObjectMethod = class_getInstanceMethod(self, @selector(safe_addObject:));
    IMP safeArrayAddObjectIMP = method_getImplementation(arrayAddObjectMethod);
    const char *safeArrayAddObjectEncoding = method_getTypeEncoding(arrayAddObjectMethod);
    
    SEL originalAddObjectSEL = @selector(addObject:);
    SEL swizzledAddObjectSEL = @selector(safe_addObject:);
    
    
    NSArray *classNames = @[@"NSArray", @"__NSArrayI", @"__NSArrayM",
                            @"__NSArray0", @"__NSSingleObjectArrayI",
                            @"__NSFrozenArrayM", @"__NSPlaceholderArray"];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        for (NSString *className in classNames) {
            Class aClass = NSClassFromString(className);
            
            // initWithObjects:count:
            swizzle(aClass, originalInitSEL, swizzledInitSEL, safeArrayInitIMP, safeArrayInitEncoding);
            
            // arrayByAddingObject
            swizzle(aClass, originalAddingSEL, swizzledAddingSEL, safeArrayAddingIMP, safeArrayAddingEncoding);
            
            // addObject
            swizzle(aClass, originalAddObjectSEL, swizzledAddObjectSEL, safeArrayAddObjectIMP, safeArrayAddObjectEncoding);
            
            // objectAtIndex:
            swizzle(aClass, originalSEL, swizzledSEL, safeIndexMethod, safeIndexEncoding);
            
            //iOS 11对所有NSArray的子类都实现了 objectAtIndexedSubscript:, 不再转发到objectAtIndex:
            //需要针对iOS 11做 objectAtIndexedSubscript: 的转换
            if (@available(iOS 11.0, *)) {
                swizzle(aClass, originalSubscriptSEL, swizzledSubscriptSEL, safeIndexSubscriptIMP, safeIndexSubscriptEncoding);
            }
        }
    });
}

- (instancetype)initWithObjects_safe:(id *)objects count:(NSUInteger)cnt {
    NSUInteger newCnt = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        if (!objects[i]) {
            break;
        }
        newCnt++;
    }
    
    return [self initWithObjects_safe:objects count:newCnt];
}

- (NSArray *)safe_arrayByAddingObject:(id)anObject {
    if (!anObject) {
        return self;
    }
    return [self safe_arrayByAddingObject:anObject];
}

- (void)safe_addObject:(id)anObject {
    if (!anObject) {
        return;
    }
    return [self safe_addObject:anObject];
}

- (id)safe_objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

- (id)safe_objectAtIndex:(NSInteger)index {
    
    if (index >= [self count] ) {
        return nil;
    }
    
    if (index < 0) {
        
        return nil;
    }
    
    return [self safe_objectAtIndex:index];
}

@end
