//
//  BRSimpleMovingAverageFilterTest.m
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
