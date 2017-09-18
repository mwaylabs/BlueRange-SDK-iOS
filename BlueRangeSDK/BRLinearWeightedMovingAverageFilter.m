//
//  BRLinearWeightedMovingAverageFilter.m
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
