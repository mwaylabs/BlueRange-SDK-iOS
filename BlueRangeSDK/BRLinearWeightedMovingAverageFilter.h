//
//  BRLinearWeightedMovingAverageFilter.h
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

#import <Foundation/Foundation.h>
#import "BRMovingAverageFilter.h"

/**
 * This class implements the {@link BRMovingAverageFilter} interface. The
 * average value is computed by linearly weighting all values, whereas
 * new values will have a greater weight than older values. The oldest
 * value defined at f(minTime) will be weighted with the constant c.
 */
@interface BRLinearWeightedMovingAverageFilter : NSObject<BRMovingAverageFilter> {
    float _c;
}

- (id) initWithC: (float) c;
- /* Override */ (float) getAverageWithStartTime: (double) startTime andEndTime: (double) endTime andTimePoints: (NSArray*) timePoints andValues: (NSArray*) values;

@end
