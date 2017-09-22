//
//  BRAnalyticalDistanceEstimator.h
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
#import "BRDistanceEstimator.h"

/**
 * This class implements an analytical distance estimator based on the path-loss formula as
 * described in: http://electronics.stackexchange
 * .com/questions/83354/calculate-distance-from-rssi or Y. Wang, X. Yang, Y. Zhao, Y. Liu, L.
 * Cuthbert, BRBluetooth positioning using rssi and triangulation methods, in: Consumer
 * Communications and Networking Conference (CCNC), 2013 IEEE, 2013, pp. 837{842.
 */
@interface BRAnalyticalDistanceEstimator : NSObject<BRDistanceEstimator>

// A is the received signal strength in dBm at 1 metre.
// We set A as described in:
// http://stackoverflow.com/questions/30177965/rssi-to-distance-with-beacons
@property float A;

// n is the propagation constant or path-loss exponent
// (Free space has n =2 for reference)
// Typically n is in the range of [0,2].
@property float N;

- (id) init;
- /* Override */ (float) getDistanceInMetres: (float) rssi withTxPower: (float) txPower;

- (float) rssiToDistance: (float) rssi;
- (float) rssiToDistance: (float) rssi withN: (float) n;
- (float) rssiToDistance: (float) rssi withA: (float) a;
- (float) rssiToDistance: (float) rssi withN: (float) n andA: (float) a;

- (float) distanceToRssi: (float) distanceInMetre;
- (float) distanceToRssi: (float) distanceInMetre withN: (float) n;
- (float) distanceToRssi: (float) distanceInMetre withA: (float) a;
- (float) distanceToRssi: (float) distanceInMetre withN: (float) n andA: (float) a;

- (float) getPropagationConstantFromRssi: (float) rssi andDistance: (float) distanceInMetre;

@end
