//
//  BRAnalyticalDistanceEstimator.m
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

#import "BRAnalyticalDistanceEstimator.h"

// http://stackoverflow.com/questions/30177965/rssi-to-distance-with-beacons
const float ANALYTICAL_DISTANCE_ESTIMATOR_DEFAULT_A = -54;
const float ANALYTICAL_DISTANCE_ESTIMATOR_DEFAULT_N = 2;

@implementation BRAnalyticalDistanceEstimator

- (id) init {
    if (self = [super init]) {
        self->_A = ANALYTICAL_DISTANCE_ESTIMATOR_DEFAULT_A;
        self->_N = ANALYTICAL_DISTANCE_ESTIMATOR_DEFAULT_N;
    }
    return self;
}

- /* Override */ (float) getDistanceInMetres: (float) rssi withTxPower: (float) txPower {
    return [self rssiToDistance:rssi withA:txPower];
}

- (float) rssiToDistance: (float) rssi {
    return [self rssiToDistance:rssi withN:self.N andA:self.A];
}

- (float) rssiToDistance: (float) rssi withN: (float) n {
    return [self rssiToDistance:rssi withN:n andA:self.A];
}

- (float) rssiToDistance: (float) rssi withA: (float) a {
    return [self rssiToDistance:rssi withN:self.N andA:a];
}

- (float) rssiToDistance: (float) rssi withN: (float) n andA: (float) a {
    float distanceInMetre = (float)(pow(10, (a-rssi)/(10*n)));
    return distanceInMetre;
}

- (float) distanceToRssi: (float) distanceInMetre {
    return [self distanceToRssi:distanceInMetre withN:self.N andA:self.A];
}

- (float) distanceToRssi: (float) distanceInMetre withN: (float) n {
    return [self distanceToRssi:distanceInMetre withN:n andA:self.A];
}

- (float) distanceToRssi: (float) distanceInMetre withA: (float) a {
    return [self distanceToRssi:distanceInMetre withN:self.N andA:a];
}

- (float) distanceToRssi: (float) distanceInMetre withN: (float) n andA: (float) a {
    float d = distanceInMetre;
    float rssi = (float)(-10*n * log10(d)+a);
    return rssi;
}

- (float) getPropagationConstantFromRssi: (float) rssi andDistance: (float) distanceInMetre {
    float n = (float)((rssi - self.A)/(-10 * log10(distanceInMetre)));
    return n;
}

@end
