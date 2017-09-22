//
//  BRLinearWeightedMovingAverageFilter.m
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

#import "BRLinearWeightedMovingAverageFilter.h"

@implementation BRLinearWeightedMovingAverageFilter

- (id) initWithC: (float) c {
    if (self = [super init]) {
        self->_c = c;
    }
    return self;
}

- /* Override */ (float) getAverageWithStartTime: (double) startTime andEndTime: (double) endTime andTimePoints: (NSArray*) timePoints andValues: (NSArray*) values {
    
    // 1. If list consists of only one value, take this value as average.
    if ([values count] == 1) {
        return [[values objectAtIndex:0] floatValue];
    }
    
    // 2. Compute weights
    NSMutableArray *weights = [[NSMutableArray alloc] init];
    double sumWeights = 0;
    for (int i = 0; i < [timePoints count]; i++) {
        double timePoint = [[timePoints objectAtIndex:i] doubleValue];
        double relativePosition = (timePoint - startTime)/(endTime - startTime);
        double m = 1.0 - self->_c;
        double weight = m*relativePosition + self->_c;
        [weights addObject:[NSNumber numberWithDouble:weight]];
        sumWeights += weight;
    }
    
    // 3. Compute the values' average by summing up all values weighted by the normalized weights.
    // Normalization means: The sum of all weights must be 1.
    double average = 0;
    for (int i = 0; i < [values count]; i++) {
        average += ([[weights objectAtIndex:i] doubleValue] / sumWeights) * [[values objectAtIndex:i] doubleValue];
    }
    return (float)average;
}

@end
