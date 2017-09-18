//
//  BRBeaconAction.m
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

#import "BRBeaconAction.h"
#import "BRAnalyticalDistanceEstimator.h"
#import "BRBeaconMessage.h"
#import "BRAbstract.h"
#import "BRBeaconCampaign.h"

NSString* const ACTION_ID_PARAMETER = @"uuid";
NSString* const TYPE_PARAMETER = @"type";
NSString* const VALID_UNTIL_PARAMETER = @"validUntil";
NSString* const POSTPONE_PARAMETER = @"postpone";
NSString* const MIN_STAY_PARAMETER = @"minStay";
NSString* const REPEAT_EVERY_PARAMETER = @"repeatEvery";
NSString* const DISTANCE_THRESHOLD_PARAMETER = @"distanceThreshold";

const long MIN_VALIDITY_BEGINS = 0;
const long MAX_VALIDITY_ENDS = LONG_MAX;
const float DEFAULT_DISTANCE_THRESHOLD = FLT_MAX;

@implementation BRBeaconAction

// Class variables
id<BRDistanceEstimator> distanceEstimator;

- (id) init {
    if (self = [super init]) {
        distanceEstimator = [[BRAnalyticalDistanceEstimator alloc] init];
        self->_sourceBeaconMessage = nil;
        self->_creationDate = [NSDate date];
        self->_campaign = nil;
        self->_actionId = nil;
        self->_validityBegins = [NSDate dateWithTimeIntervalSince1970:MIN_VALIDITY_BEGINS];
        self->_validityEnds = [NSDate dateWithTimeIntervalSince1970:MAX_VALIDITY_ENDS];
        self->_isDelaying = false;
        self->_isLockingAction = false;
        self->_releaseLockAfterMs = 0L;
        self->_startLockDate = nil;
        self->_lockReleaseDate = nil;
        self->_distanceThreshold = DEFAULT_DISTANCE_THRESHOLD;
    }
    return self;
}

+ (void) setDistanceEstimator: (id<BRDistanceEstimator>) _distanceEstimator {
    distanceEstimator = _distanceEstimator;
}

+ (id<BRDistanceEstimator>) distanceEstimator {
    return distanceEstimator;
}

- (float) distanceEstimationInMetres {
    // To compare the measured RSSI based on the txPower,
    // we simply need to add the difference between the
    // calibrated and the fixed txPower. This can be shown
    // be computing a distance estimation for the RSSI
    // using the path loss formula:
    // distance = (Math.pow(10, (A-rssi)/(10*n)))
    // First compute the distance based on the calibrated txPower (A_calibrated)
    // and then recompute the RSSI using a fixed txPower (A_fixed).
    // The resulting equation can be simplified to:
    // Rssi_normalized = Rssi_measured - A_calibrated + A_fixed
    int measuredRssi = self.sourceBeaconMessage.rssi;
    int calibratedTxPower = self.sourceBeaconMessage.txPower;
    float distancesInMetres = [distanceEstimator getDistanceInMetres:measuredRssi withTxPower:calibratedTxPower];
    return distancesInMetres;
}

- (BOOL) isExpired {
    NSTimeInterval actionValidityEnds = [self.validityEnds timeIntervalSince1970];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return now > actionValidityEnds;
}

- (BOOL) isDelayed {
    NSTimeInterval validityBegins = [self.validityBegins timeIntervalSince1970];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return now < validityBegins;
}

- (BOOL) lockExpired {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval lockReleaseDateInMs = [self.lockReleaseDate timeIntervalSince1970];
    return now > lockReleaseDateInMs;
}

- (BOOL) isOutOfRange {
    float distanceInMetres = [self distanceEstimationInMetres];
    return distanceInMetres > self.distanceThreshold;
}

- (BOOL) isCampaignExpired {
    NSTimeInterval campaignValidityEndsInMs = [self.campaign.endsDate timeIntervalSince1970];
    NSTimeInterval nowInMs = [[NSDate date] timeIntervalSince1970];
    return nowInMs > campaignValidityEndsInMs;
}

- (BOOL) isCampaignInactive {
    NSTimeInterval campaignValidityBeginsInMs = [self.campaign.beginsDate timeIntervalSince1970];
    NSTimeInterval nowInMs = [[NSDate date] timeIntervalSince1970];
    return nowInMs < campaignValidityBeginsInMs;
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[BRBeaconAction class]]) {
        return false;
    }
    BRBeaconAction *action = (BRBeaconAction*)object;
    return [action.actionId isEqualToString:self.actionId];
}

- /*BRAbstract*/ (NSString*) type {
    mustOverride();
}

- /*BRAbstract*/ (BRBeaconAction*) newCopy {
    mustOverride();
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BRBeaconAction* newAction = [self newCopy];
    newAction->_sourceBeaconMessage = _sourceBeaconMessage;
    newAction->_creationDate = _creationDate;
    newAction->_campaign = _campaign;
    newAction->_actionId = _actionId;
    newAction->_validityBegins = _validityBegins;
    newAction->_validityEnds = _validityEnds;
    newAction->_isDelaying = _isDelaying;
    newAction->_isLockingAction = _isLockingAction;
    newAction->_releaseLockAfterMs = _releaseLockAfterMs;
    newAction->_startLockDate = _startLockDate;
    newAction->_lockReleaseDate = _lockReleaseDate;
    newAction->_distanceThreshold = _distanceThreshold;
    return newAction;
}

- /* BRAbstract */ (NSUInteger) hash {
    mustOverride();
}

@end
