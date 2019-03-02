//
//  NSDictionarySafeTest.m
//  SafeKitTests
//
//  Created by 张银龙 on 2019/3/2.
//  Copyright © 2019 yinlong. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSDictionarySafeTest : XCTestCase

@end

@implementation NSDictionarySafeTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test__init {
    NSString *nilValue = nil;
    NSDictionary *dict = @{
                           @"key1" : @"value1",
                           @"key2" : @"value2",
                           @"key3" : nilValue,
                           @"key4" : @"value4",
                           }.copy;
    
    XCTAssert([dict[@"key1"] isEqualToString:@"value1"]);
    XCTAssert([dict[@"key2"] isEqualToString:@"value2"]);
    XCTAssert(dict[@"key3"] == nil);
    XCTAssert(dict[@"key4"] == nil);
    XCTAssert(dict.count  == 2);
    
}

- (void)test__set {
    
    NSString *nilValue = nil;
    
    NSMutableDictionary *dict = @{
                                  @"key1" : @"value1",
                                  @"key2" : @"value2",
                                  @"key3" : nilValue,
                                  @"key4" : @"value4",
                                  }.mutableCopy;
    
    XCTAssert([dict[@"key1"] isEqualToString:@"value1"]);
    XCTAssert([dict[@"key2"] isEqualToString:@"value2"]);
    XCTAssert(dict[@"key3"] == nil);
    XCTAssert(dict[@"key4"] == nil);
    XCTAssert(dict.count  == 2);
    
    [dict setObject:@"value5" forKey:@"key5"];
    XCTAssert(dict.count  == 3);
    
    [dict setObject:@"value6" forKey:nilValue];
    XCTAssert(dict.count  == 3);
    [dict setObject:nilValue forKey:@"key6"];
    XCTAssert(dict.count  == 3);
    
    dict[@"key7"] = @"value7";
    XCTAssert(dict.count  == 4);
    
    dict[nilValue] = @"value8";
    XCTAssert(dict.count  == 4);
    
    dict[@"key9"] = nilValue;
    XCTAssert(dict.count  == 4);
    
    
    dict[@"key1"] = nilValue;
    XCTAssert(dict.count  == 3);
}


- (void)test__remove {
    NSString *nilValue = nil;
    
    NSMutableDictionary *dict = @{
                                  @"key1" : @"value1",
                                  @"key2" : @"value2",
                                  @"key3" : nilValue,
                                  @"key4" : @"value4",
                                  }.mutableCopy;
    
    XCTAssert([dict[@"key1"] isEqualToString:@"value1"]);
    XCTAssert([dict[@"key2"] isEqualToString:@"value2"]);
    XCTAssert(dict[@"key3"] == nil);
    XCTAssert(dict[@"key4"] == nil);
    XCTAssert(dict.count  == 2);
    
    [dict removeObjectForKey:nilValue];
    XCTAssert(dict.count  == 2);
    [dict removeObjectForKey:@"key4"];
    XCTAssert(dict.count  == 2);
    [dict removeObjectForKey:@"key1"];
    XCTAssert(dict.count  == 1);
    
    
}

@end
