//
//  BRBeaconTrigger.m
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

#import "BRBeaconTrigger.h"
#import "BRIBeaconMessageScanner.h"
#import "BRBeaconMessage.h"
#import "BRBeaconMessageAggregator.h"
#import "BRRelutionTagMessageV1.h"
#import "BRIBeaconMessage.h"
#import "BRRelutionTagMessage.h"
#import "BRBeaconJoinMeMessage.h"
#import "BRIBeacon.h"
#import "BRDistanceEstimator.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRTracer.h"
#import "BRAnalyticalDistanceEstimator.h"

// BRConstants
const int TXPOWER = -55;
const long MESSAGE_OUTDATED_IN_MS = 10 * 1000;

// Private methods
@interface BRBeaconTrigger()

// Initialization
- (void) initScanner: (BRIBeaconMessageScanner*) scanner;
- (void) initAggregator;
- (void) onUpdateMessage: (BRBeaconMessage*) message;
- (BOOL) relutionTagMessageContainsAtLeastOneMatchingTag: (BRRelutionTagMessageV1*) relutionTagMessage tagList: (NSArray*) tags;
- (BOOL) existsTriggeringIBeacon: (BRIBeaconMessage*) iBeaconMessage allowedIBeacons: (NSArray*) allowedIBeacons;
- (void) updateMessage: (BRBeaconMessage*) message;
- (float) estimateDistanceInMeters: (BRBeaconMessage*) message;
- (void) updateDistance: (BRBeaconMessage*) message distance: (float) distanceInMeter;
- (void) updateTimestamp: (BRBeaconMessage*) message;
- (BOOL) isNoBeaconActive: (BRBeaconMessage*) message;
- (BOOL) beaconWinsRace: (BRBeaconMessage*) message andDistance: (float) distance;
- (BOOL) isBeaconActive:(BRBeaconMessage *)message;
- (void) activateBeacon: (BRBeaconMessage*) message;
- (void) notifyObserversAboutBeaconActivation: (BRBeaconMessage*) message;
- (void) refreshTimer: (BRBeaconMessage*) message;
- (void) notifyObserversAboutBeaconInactivation: (BRBeaconMessage*) message;
- (void) inactivateBeacon: (BRBeaconMessage*) message;

@end

@implementation BRBeaconTrigger

// Initialization

- (id) initWithTracer: (id<BRITracer>) tracer andScanner: (BRIBeaconMessageScanner*) scanner {
    return [self initWithTracer:tracer andScanner:scanner andDistanceEstimator: [[BRAnalyticalDistanceEstimator alloc] init]];
}

- (id) initWithTracer: (id<BRITracer>) tracer andScanner: (BRIBeaconMessageScanner*) scanner
 andDistanceEstimator: (id<BRDistanceEstimator>) distanceEstimator {
    if (self = [super init]) {
        self->_multiBeaconMode = true;
        self->_activeBeacons = [[NSMutableDictionary alloc] init];
        self->_distances = [[NSMutableDictionary alloc] init];
        self->_timestamps = [[NSMutableDictionary alloc] init];
        
        
        self->_tracer = tracer;
        self->_distanceEstimator = distanceEstimator;
        self->_activationDistanceInMeter = 0.5f;
        self->_inactivationDistanceInMeter = 1.5f;
        // Must be high, because the beacon does not constantly send messages.
        // Sometimes we have a pause of about 4 seconds.
        self->_inactivationDurationInMs = 0;
        self->_minDistanceDifferenceToActivateInM = 0.6f;
        self->_activeBeacons = [[NSMutableDictionary alloc] init];
        self->_timers = [[NSMutableDictionary alloc] init];
        self->_observers = [[NSMutableArray alloc] init];
        
        self->_allowedRelutionTags = [[NSMutableArray alloc] init];
        self->_allowedIBeacons = [[NSMutableArray alloc] init];
        
        [self initScanner:scanner];
        [self initAggregator];
        // Observer registration
        [self->_aggregator addReceiver:self];
        
    }
    return self;
}

- (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    [self onUpdateMessage:message];
}

- (void) initScanner: (BRIBeaconMessageScanner*) scanner {
    self->_scanner = scanner;
}

- (void) initAggregator {
    // Avoid premature state transitions from inactive to active
    // by using a message aggregator in sliding window mode.
    self->_aggregator = [[BRBeaconMessageAggregator alloc] initWithTracer:_tracer andSender:_scanner];
    [self setReactionMode:SLIDING_WINDOW];
    [self setReactionDurationInMs:1000L];
}

- (void) onUpdateMessage: (BRBeaconMessage*) message {
    if ([message isKindOfClass:[BRRelutionTagMessageV1 class]]) {
        BRRelutionTagMessageV1* relutionTagMessage = (BRRelutionTagMessageV1*)message;
        if ([self relutionTagMessageContainsAtLeastOneMatchingTag:relutionTagMessage tagList:self->_allowedRelutionTags]) {
            [self updateMessage:message];
        }
    } else if ([message isKindOfClass:[BRIBeaconMessage class]]) {
        BRIBeaconMessage* iBeaconMessage = (BRIBeaconMessage*)message;
        if ([self existsTriggeringIBeacon:iBeaconMessage allowedIBeacons:self->_allowedIBeacons]) {
            [self updateMessage:message];
        }
    } else if ([message isKindOfClass:[BRBeaconJoinMeMessage class]]) {
        
    }
}

- (BOOL) relutionTagMessageContainsAtLeastOneMatchingTag: (BRRelutionTagMessageV1*) relutionTagMessage tagList: (NSArray*) tags {
    for (int i = 0; i < [tags count]; i++) {
        long filterTag = [[tags objectAtIndex:i] longValue];
        for (int j = 0; j < [relutionTagMessage.tags count]; j++) {
            long messageTag = [[relutionTagMessage.tags objectAtIndex:j] longValue];
            if (filterTag == messageTag) {
                return true;
            }
        }
    }
    return false;
}

- (BOOL) existsTriggeringIBeacon: (BRIBeaconMessage*) iBeaconMessage allowedIBeacons: (NSArray*) allowedIBeacons {
    for (BRIBeacon* iBeacon in allowedIBeacons) {
        BRIBeacon* receivedIBeacon = [iBeaconMessage iBeacon];
        if ([iBeacon isEqual:receivedIBeacon]) {
            return true;
        }
    }
    return false;
}

- (void) updateMessage: (BRBeaconMessage*) message {
    float distanceInMeters = [self estimateDistanceInMeters:message];
    
    // Save distance
    [self updateDistance:message distance:distanceInMeters];
    [self updateTimestamp:message];
    
    // Notify distance observers
    for (id<BRBeaconTriggerObserver> observer in _observers) {
        [observer onNewDistance:message distance:distanceInMeters];
    }
    
    // State changes
    if (distanceInMeters <= _activationDistanceInMeter) {
        if (!_multiBeaconMode) {
            if ([self isNoBeaconActive:message]) {
                [self notifyObserversAboutBeaconActivation:message];
                [self activateBeacon:message];
            }
        } else {
            if ([self beaconWinsRace:message andDistance:distanceInMeters]) {
                [self notifyObserversAboutBeaconActivation:message];
                [self activateBeacon:message];
            }
        }
    }
    if (!_multiBeaconMode) {
        if ([self isBeaconActive:message] && (distanceInMeters <= _inactivationDistanceInMeter)) {
            [self refreshTimer:message];
        }
    }
}

- (float) estimateDistanceInMeters: (BRBeaconMessage*) message {
    int rssi = [message rssi];
    int txPower = TXPOWER;
    return [_distanceEstimator getDistanceInMetres:rssi withTxPower:txPower];
}

- (void) updateDistance: (BRBeaconMessage*) message distance: (float) distanceInMeter {
    [self->_distances setObject:[NSNumber numberWithFloat:distanceInMeter] forKey:message];
}

- (void) updateTimestamp: (BRBeaconMessage*) message {
    [self->_timestamps setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] ] forKey:message];
}

- (BOOL) isNoBeaconActive: (BRBeaconMessage*) message {
    for (BRBeaconMessage* beacon in [self->_activeBeacons allKeys]) {
        if ([self isNoBeaconActive:beacon]) {
            return false;
        }
    }
    return true;
}

- (BOOL) beaconWinsRace: (BRBeaconMessage*) message andDistance: (float) distance {
    for (BRBeaconMessage* beaconMessage in [self->_distances allKeys]) {
        float beaconDistance = [[self->_distances objectForKey:beaconMessage] floatValue];
        // Do not compare with the same message
        if (![beaconMessage isEqual:message]) {
            // Do not compare with messages that are "outdated".
            long long nowInMs = [[NSDate date] timeIntervalSince1970] * 1000;
            long long messageTimestampInMs = [[self->_timestamps objectForKey:beaconMessage] longLongValue] * 1000;
            if (nowInMs - messageTimestampInMs < MESSAGE_OUTDATED_IN_MS) {
                if (!(distance <= beaconDistance - self->_minDistanceDifferenceToActivateInM)) {
                    return false;
                }
            }
        }
    }
    return true;
}

- (BOOL) isBeaconActive:(BRBeaconMessage*) message {
    NSNumber* active = [self->_activeBeacons objectForKey:message];
    if (active != nil) {
        return [active boolValue];
    } else {
        return false;
    }
}

- (void) activateBeacon: (BRBeaconMessage*) message {
    [self->_activeBeacons setObject:[NSNumber numberWithBool:TRUE] forKey:message];
}

- (void) notifyObserversAboutBeaconActivation: (BRBeaconMessage*) message {
    for (id<BRBeaconTriggerObserver> observer in self->_observers) {
        [observer onBeaconActive:message];
    }
}

- (void) refreshTimer: (BRBeaconMessage*) message {
    if (self->_inactivationDurationInMs != 0) {
        NSTimer* timer = [_timers objectForKey:message];
        if (timer != nil) {
            [timer invalidate];
        }
        
        // User info
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:message forKey:@"message"];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:((float)_inactivationDurationInMs)/1000
                                                 target:self selector:@selector(onTimerElapsed:)
                                               userInfo:userInfo repeats:false];
        [_timers setObject:timer forKey:message];
    }
}

- (void) onTimerElapsed:(NSTimer*)timer {
    NSDictionary* userInfo = [timer userInfo];
    BRBeaconMessage* message = [userInfo objectForKey:@"message"];
    [self notifyObserversAboutBeaconActivation:message];
    [self inactivateBeacon:message];
}

- (void) notifyObserversAboutBeaconInactivation: (BRBeaconMessage*) message {
    for (id<BRBeaconTriggerObserver> observer in self->_observers) {
        [observer onBeaconInactive:message];
    }
}

- (void) inactivateBeacon: (BRBeaconMessage*) message {
    [self->_activeBeacons setObject:[NSNumber numberWithBool:false] forKey:message];
}

// Life cycle
- (void) stop {
    for (NSTimer* timer in [self->_timers allValues]) {
        if (timer != nil) {
            [timer invalidate];
        }
    }
}

// Triggers
- (void) addRelutionTagTrigger: (long) tag {
    [self->_allowedRelutionTags addObject:[NSNumber numberWithLong:tag]];
    BRBeaconMessageScannerConfig* config = [_scanner config];
    [config scanRelutionTagsV1:@[[NSNumber numberWithLong:tag]]];
}

- (void) addRelutionTagTriggers: (NSArray*) tags {
    NSMutableArray* tagList = [[NSMutableArray alloc] init];
    for (int i = 0; i < [tags count]; i++) {
        long tag = [[tags objectAtIndex:i] longValue];
        [tagList addObject:[NSNumber numberWithLong:tag]];
    }
    [self->_allowedRelutionTags addObjectsFromArray:tagList];
    BRBeaconMessageScannerConfig* config = [_scanner config];
    [config scanRelutionTagsV1:tags];
}

- (void) addIBeaconTrigger: (NSUUID*) uuid andMajor: (int) major andMinor: (int) minor  {
    BRIBeacon* iBeacon = [[BRIBeacon alloc] initWithUuid:uuid andMajor:major andMinor:minor];
    [self->_allowedIBeacons addObject:iBeacon];
    BRBeaconMessageScannerConfig* config = [_scanner config];
    [config scanIBeacon:uuid.UUIDString major:major minor:minor];
}

- (void) addIBeaconTriggers: (NSArray*) iBeacons {
    [self->_allowedIBeacons addObjectsFromArray:iBeacons];
    BRBeaconMessageScannerConfig* config = [_scanner config];
    [config scanIBeacons:iBeacons];
}

- (void) addObserver: (id<BRBeaconTriggerObserver>) observer {
    [self->_observers addObject:observer];
}

// Reaction
- (void) setReactionDurationInMs: (long) reflectionTimeInMs {
    [self->_aggregator setAggregateDurationInMs:reflectionTimeInMs];
}

- (long) getReactionTimeInMs {
    return [self->_aggregator aggregateDurationInMs];
}

- (void) setReactionMode: (ReactionMode) reactionMode {
    if (reactionMode == SLIDING_WINDOW) {
        [self->_aggregator setAggregationMode:AGGREGATION_MODE_SLIDING_WINDOW];
    } else if (reactionMode == PACKET) {
        [self->_aggregator setAggregationMode:AGGREGATION_MODE_PACKET];
    }
}

- (ReactionMode) getReactionMode {
    if ([self->_aggregator aggregationMode] == AGGREGATION_MODE_SLIDING_WINDOW) {
        return SLIDING_WINDOW;
    } else {
        return PACKET;
    }
}

@end
