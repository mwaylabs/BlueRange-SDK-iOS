//
//  BRBeaconTrigger.h
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
