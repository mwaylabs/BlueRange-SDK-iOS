//
//  BRAnalyticalDistanceEstimator.m
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
