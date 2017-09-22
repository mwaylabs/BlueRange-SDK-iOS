//
//  BRBeaconAction.m
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
