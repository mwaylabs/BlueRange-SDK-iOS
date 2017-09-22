//
//  BRSimpleMovingAverageFilterTest.m
//  BlueRangeSDK
//
// Copyright (c) 2016-2017, M-Way Solutions GmbH
// All rights reserved.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

#import <XCTest/XCTest.h>
#import "BRSimpleMovingAverageFilter.h"

@interface BRSimpleMovingAverageFilterTest : XCTestCase

@property BRSimpleMovingAverageFilter* filter;

@end

@implementation BRSimpleMovingAverageFilterTest

- (void)setUp {
    [super setUp];
    self.filter = [[BRSimpleMovingAverageFilter alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testAverageWithOneValue {
    float expectedValue = 10;
    
    long minTime = 0;
    long maxTime = 1;
    NSMutableArray* timePoints = [[NSMutableArray alloc] init];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    [timePoints addObject:[NSNumber numberWithLong:0l]];
    [values addObject:[NSNumber numberWithLong:expectedValue]];
    
    float actualValue = [self.filter getAverageWithStartTime:minTime andEndTime:maxTime andTimePoints:timePoints andValues:values];
    
    XCTAssertEqualWithAccuracy(expectedValue, actualValue, 0.1);
}

- (void) testAverageWithTwoValues {
    long minTime = 0;
    long maxTime = 1;
    NSMutableArray* timePoints = [[NSMutableArray alloc] init];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    [timePoints addObject:[NSNumber numberWithLong:0l]];
    [values addObject:[NSNumber numberWithLong:1l]];
    [timePoints addObject:[NSNumber numberWithLong:1l]];
    [values addObject:[NSNumber numberWithLong:2l]];
    
    float actualValue = [self.filter getAverageWithStartTime:minTime andEndTime:maxTime andTimePoints:timePoints andValues:values];
    
    XCTAssertEqualWithAccuracy(1.5l, actualValue, 0.1);
}

@end
