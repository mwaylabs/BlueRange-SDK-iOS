//
//  BRAnalyticalDistanceEstimator.h
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
