//
//  BRBeaconTrigger.h
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
#import "BRITracer.h"
#import "BRBeaconMessageStreamNodeDefaultReceiver.h"

@class BRIBeaconMessageScanner;
@class BRBeaconMessageFilter;
@class BRBeaconMessageAggregator;
@class BRBeaconMessage;

@protocol BRDistanceEstimator;

@protocol BRBeaconTriggerObserver

- (void) onBeaconActive: (BRBeaconMessage*) message;
- (void) onBeaconInactive: (BRBeaconMessage*) message;
- (void) onNewDistance: (BRBeaconMessage*) message distance: (float) distance;

@end

typedef enum {
    PACKET,
    SLIDING_WINDOW,
    
} ReactionMode;

@interface BRBeaconTrigger : BRBeaconMessageStreamNodeDefaultReceiver {
    // Tracing
    id<BRITracer> _tracer;
    
    // Message processing
    BRIBeaconMessageScanner* _scanner;
    BRBeaconMessageFilter* _filter;
    BRBeaconMessageAggregator *_aggregator;
    
    // Filtering
    NSMutableArray* _allowedRelutionTags;
    NSMutableArray* _allowedIBeacons;
    
    // Configuration
    id<BRDistanceEstimator> _distanceEstimator;
    
    // State
    NSMutableDictionary* _activeBeacons;
    NSMutableDictionary* _distances;
    NSMutableDictionary* _timestamps;
    NSMutableDictionary* _timers;
    
    // Observer
    NSMutableArray* _observers;
}

// Multi beacon mode. The nearest beacon is active.
// Beacon will be activated whenever a message is received
// with a distance difference to all other beacons of at
// least "minDistanceDifferenceToActivate".
@property BOOL multiBeaconMode;
@property float minDistanceDifferenceToActivateInM;

// Configuration
@property float activationDistanceInMeter;
@property float inactivationDistanceInMeter;
@property float inactivationDurationInMs;

// Initialization
- (id) initWithTracer: (id<BRITracer>) tracer andScanner: (BRIBeaconMessageScanner*) scanner;
- (id) initWithTracer: (id<BRITracer>) tracer andScanner: (BRIBeaconMessageScanner*) scanner
    andDistanceEstimator: (id<BRDistanceEstimator>) distanceEstimator;

// Life cycle
- (void) stop;

// Triggers
- (void) addRelutionTagTrigger: (long) tag;
- (void) addRelutionTagTriggers: (NSArray*) tags;
- (void) addIBeaconTrigger: (NSUUID*) uuid andMajor: (int) major andMinor: (int) minor;
- (void) addIBeaconTriggers: (NSArray*) iBeacons;
- (void) addObserver: (id<BRBeaconTriggerObserver>) observer;

// Reaction
- (void) setReactionDurationInMs: (long) reflectionTimeInMs;
- (long) getReactionTimeInMs;
- (void) setReactionMode: (ReactionMode) reactionMode;
- (ReactionMode) getReactionMode;

@end
