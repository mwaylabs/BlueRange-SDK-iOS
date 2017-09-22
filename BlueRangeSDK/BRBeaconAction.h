//
//  BRBeaconAction.h
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

@protocol BRDistanceEstimator;
@class BRBeaconMessage;
@class BRBeaconCampaign;

// BRConstants
extern NSString* const ACTION_ID_PARAMETER;
extern NSString* const TYPE_PARAMETER;
extern NSString* const VALID_UNTIL_PARAMETER;
extern NSString* const POSTPONE_PARAMETER;
extern NSString* const MIN_STAY_PARAMETER;
extern NSString* const REPEAT_EVERY_PARAMETER;
extern NSString* const DISTANCE_THRESHOLD_PARAMETER;

extern const long MIN_VALIDITY_BEGINS;
extern const long MAX_VALIDITY_ENDS;
extern const float DEFAULT_DISTANCE_THRESHOLD;

@interface BRBeaconAction : NSObject<NSCopying>

// Class variables
extern id<BRDistanceEstimator> distanceEstimator;

// Instance variables
@property BRBeaconMessage* sourceBeaconMessage;
@property (readonly) NSDate* creationDate;
@property BRBeaconCampaign* campaign;
@property NSString* actionId;
@property NSDate* validityBegins;
@property NSDate* validityEnds;
@property BOOL isDelaying;
@property BOOL isLockingAction;
@property long releaseLockAfterMs;
@property NSDate* startLockDate;
@property NSDate* lockReleaseDate;
@property float distanceThreshold;

// Methods
- (id) init;

+ (void) setDistanceEstimator: (id<BRDistanceEstimator>) distanceEstimator;
+ (id<BRDistanceEstimator>) distanceEstimator;
- (float) distanceEstimationInMetres;

- (BOOL) isExpired;
- (BOOL) isDelayed;
- (BOOL) lockExpired;
- (BOOL) isOutOfRange;
- (BOOL) isCampaignExpired;
- (BOOL) isCampaignInactive;

- (BOOL) isEqual:(id)object;

- /*BRAbstract*/ (NSString*) type;
- /*BRAbstract*/ (BRBeaconAction*) newCopy;

- (id)copyWithZone:(struct _NSZone *)zone;

- /* BRAbstract */ (NSUInteger) hash;

@end
