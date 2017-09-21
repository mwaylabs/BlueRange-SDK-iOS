//
//  BRLinearWeightedMovingAverageFilterTest.m
//  BlueRangeSDK
//
// Copyright (c) 2016-2017, M-Way Solutions GmbH
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the M-Way Solutions GmbH nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY M-Way Solutions GmbH ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL M-Way Solutions GmbH BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
