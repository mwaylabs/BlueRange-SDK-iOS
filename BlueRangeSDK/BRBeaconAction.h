//
//  BRBeaconAction.h
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
