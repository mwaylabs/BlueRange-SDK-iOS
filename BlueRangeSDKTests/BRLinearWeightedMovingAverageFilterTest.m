//
//  BRLinearWeightedMovingAverageFilterTest.m
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
#import "BRLinearWeightedMovingAverageFilter.h"

@interface BRLinearWeightedMovingAverageFilterTest : XCTestCase

@end

@implementation BRLinearWeightedMovingAverageFilterTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testAverageWithOneValue {
    
    float expectedValue = 10;
    BRLinearWeightedMovingAverageFilter* filter = [[BRLinearWeightedMovingAverageFilter alloc] initWithC:0.0];
    long minTime = 0;
    long maxTime = 0;
    NSMutableArray* timePoints = [[NSMutableArray alloc] init];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    [timePoints addObject:[NSNumber numberWithInt:0]];
    [values addObject:[NSNumber numberWithInt:expectedValue]];
    
    float actualValue = [filter getAverageWithStartTime:minTime andEndTime:maxTime andTimePoints:timePoints andValues:values];
    
    XCTAssertEqualWithAccuracy(actualValue, expectedValue, 0.1);
}

- (void) testAverageWithTwoValues {
    BRLinearWeightedMovingAverageFilter* filter = [[BRLinearWeightedMovingAverageFilter alloc] initWithC:0.0];
    long minTime = 0;
    long maxTime = 1;
    NSMutableArray* timePoints = [[NSMutableArray alloc] init];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    [timePoints addObject:[NSNumber numberWithLong:0]];
    [values addObject:[NSNumber numberWithLong:1]];
    [timePoints addObject:[NSNumber numberWithLong:1l]];
    [values addObject:[NSNumber numberWithLong:2l]];
    
    float actualValue = [filter getAverageWithStartTime:minTime andEndTime:maxTime andTimePoints:timePoints andValues:values];
    
    XCTAssertEqualWithAccuracy(2, actualValue, 0.1);
}

- (void) testAverageWithNonNormalizedTimeSpan {
    BRLinearWeightedMovingAverageFilter* filter = [[BRLinearWeightedMovingAverageFilter alloc] initWithC:0.0];
    long minTime = 0;
    long maxTime = 2;
    NSMutableArray* timePoints = [[NSMutableArray alloc] init];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    [timePoints addObject:[NSNumber numberWithLong:0]];
    [values addObject:[NSNumber numberWithLong:1]];
    [timePoints addObject:[NSNumber numberWithLong:1l]];
    [values addObject:[NSNumber numberWithLong:2l]];
    
    float actualValue = [filter getAverageWithStartTime:minTime andEndTime:maxTime andTimePoints:timePoints andValues:values];
    
    XCTAssertEqualWithAccuracy(2, actualValue, 0.1);
}

- (void) testAverageWithNonZeroC {
    BRLinearWeightedMovingAverageFilter* filter = [[BRLinearWeightedMovingAverageFilter alloc] initWithC:0.5];
    long minTime = 0;
    long maxTime = 2;
    NSMutableArray* timePoints = [[NSMutableArray alloc] init];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    [timePoints addObject:[NSNumber numberWithLong:0]];
    [values addObject:[NSNumber numberWithLong:1]];
    [timePoints addObject:[NSNumber numberWithLong:2l]];
    [values addObject:[NSNumber numberWithLong:2l]];
    
    float actualValue = [filter getAverageWithStartTime:minTime andEndTime:maxTime andTimePoints:timePoints andValues:values];
    
    XCTAssertEqualWithAccuracy(actualValue, ((1.0/3)*1.0) + ((2.0/3)*2), 0.1);
}

@end
