//
//  NSArraySafeTest.m
//  SafeKit
//
//  Created by 张银龙 on 2019/3/1.
//  Copyright © 2019 yinlong. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+SafeKit.h"

@interface NSArraySafeTest : XCTestCase

@end

@implementation NSArraySafeTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test__NSArray0 {
    NSArray *__arr0 = @[];

    NSString *valueSubscriptNil = __arr0[100];
    NSString *valueNil = [__arr0 objectAtIndex:100];
    XCTAssert(valueSubscriptNil == nil);
    XCTAssert(valueNil == nil);

}

- (void)test__NSArraySingleObjectArrayI {
    NSArray *singleArr = @[@"1"];
    NSString *value = singleArr[0];
    NSString *valueSubscriptNil = singleArr[100];
    NSString *valueNil = [singleArr objectAtIndex:100];
    XCTAssert([value isEqualToString:@"1"]);
    XCTAssert(valueSubscriptNil == nil);
    XCTAssert(valueNil == nil);
}

- (void)test__NSArrayI {
    NSArray *arr = @[@"1", @"2"];
    NSString *value = arr[0];
    NSString *valueSubscriptNil = arr[100];
    NSString *valueNil = [arr objectAtIndex:100];
    XCTAssert([value isEqualToString:@"1"]);
    XCTAssert(valueSubscriptNil == nil);
    XCTAssert(valueNil == nil);
}

- (void)test__NSArrayM {
    NSArray *arr = @[@"1", @"2"].mutableCopy;
    NSString *value = arr[0];
    NSString *valueSubscriptNil = arr[100];
    NSString *valueNil = [arr objectAtIndex:100];
    XCTAssert([value isEqualToString:@"1"]);
    XCTAssert(valueSubscriptNil == nil);
    XCTAssert(valueNil == nil);
}

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

@end
