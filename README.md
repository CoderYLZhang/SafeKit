# SafeKit

### Exchange the method in NSArray,NSDictionary

```objective-c

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
```

### Unit Test

```objective-c

- (void)test__init {
    NSString *nilValue = nil;
    NSArray *arr = @[@"1", nilValue, @"2"];
    NSString *value = arr[0];
    NSString *value1 = arr[1];
    NSString *valueSubscriptNil = arr[100];
    NSString *valueNil = [arr objectAtIndex:100];
    XCTAssert([value isEqualToString:@"1"]);
    XCTAssert(value1 == nil);
    XCTAssert(valueSubscriptNil == nil);
    XCTAssert(valueNil == nil);
}

- (void)test__adding {
    id value = nil;
    NSArray *arr = @[];
    [arr arrayByAddingObject:value];
    
    NSMutableArray *arrM = @[].mutableCopy;
    [arrM arrayByAddingObject:value];
    [arrM arrayByAddingObjectsFromArray:@[value]];
    [arrM addObject:value];
}
```



### Contributions

Contributions are totally welcome. We'll review all pull requests and if you send us a good one/are interested we're happy to give you push access to the repo. Or, you know, you could just come work with us.<br>

Please pay attention to add Star, your support is my greatest motivation, thank you.