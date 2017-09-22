//
//  BRBeaconMessageActionTrigger.h
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
#import "BRBeaconMessagePassingStreamNode.h"

// Forward declrations
@protocol BRITracer;
@protocol BRDistanceEstimator;
@protocol BRIBeaconMessageActionMapper;
@protocol BRRelutionTagMessageActionMapper;
@protocol BRBeaconActionListener;
@protocol BRBeaconActionDebugListener;
@class BRBeaconMessageAggregator;
@class BRBeaconMessageQueuedStreamNode;
@class BRRunningFlag;
@class BRBeaconActionRegistry;
@class BRBeaconActionLocker;
@class BRBeaconActionExecutor;

/**
 * A trigger instance is a node in a message processing graph that is able to trigger actions,
 * whenever messages will be received, that an action registry is able to map to an action.<br>
 *     Before an action will be triggered, the message stream is filtered, so that only iBeacon
 *     and Relution Tag messages will be considered in the further steps. To stabilize the RSSI
 *     values of the incoming messages, a message aggregator aggregates equivalent messages and
 *     averages the RSSI values by using a linearly weighted moving average filter. The resulting
 *     stream of aggregated messages is then delivered to a message queue, which the trigger
 *     iteratively pulls messages out of. Each message is then mapped to an action using the
 *     action registry, which can e.g. call a remote webservice. If the registry is not currently
 *     available, the trigger mechanism waits until the registry has become available. In this
 *     time the message queue will in most cases accumulate a lot of messages. Since the queue,
 *     however, has a limited size, these situations will not result in a memory leak. The
 *     advantage of this strategy, however, is, that actions can be executed at a later time, e.g
 *     . when internet has become available.<br> Before an action will be executed, it has to
 *     pass a sequence of checks, since actions can be equipped with different time and location
 *     based parameters. One of these parameters is a distance threshold. The action executor
 *     first transforms the RSSI value of the action initiating message to a distance value and
 *     then checks whether this value is below a distance threshold being defined in the action's
 *     description. If this is not the case, the action will be discarded. In the other case the
 *     executor checks, whether the action validation period is expired. An expiration will also
 *     result in an action discard. Another situation, when an action will be discarded, occurs,
 *     when an equivalent action has set a lock to this action for a specific duration. As long
 *     as the lock is set, no actions with the same action ID will be executed. If the action
 *     should be executed with a delay, it will be added to an action delay queue and executed
 *     when the delay time has elapsed.
 */
@interface BRBeaconMessageActionTrigger : BRBeaconMessagePassingStreamNode {
    // BRTracer
    id<BRITracer> _tracer;
    
    // Debugging
    NSMutableArray* _debugActionListeners;
    
    // Sender nodes
    BRBeaconMessageQueuedStreamNode* _queueNode;
    
    // Triggering
    BRRunningFlag* _runningFlag;
    NSThread *_messageProcessingThread;
    
    // Action registry
    BRBeaconActionRegistry* _actionRegistry;
    
    // Action delaying
    NSMutableArray* _delayedActions;
    NSThread* _delayedActionExecutionThread;
    
    // Action locking
    BRBeaconActionLocker* _actionLocker;
    
    // Action execution
        // The action executors form a chain of responsibility.
    BRBeaconActionExecutor* _actionExecutorChain;
}

// Debugging
@property BOOL debugModeOn;

// Sender nodes
@property (readonly) BRBeaconMessageAggregator* aggregator;

// Action distancing
@property id<BRDistanceEstimator> distanceEstimator;

// Initialization method
- (id) initWithSender: (BRBeaconMessageStreamNode*) senderNode
    andIBeaconMessageActionMapper: (id<BRIBeaconMessageActionMapper>) iBeaconActionMapper
    andRelutionTagMessageActionMapper: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper;
- (id) initWithTracer:(id<BRITracer>) tracer andSender: (BRBeaconMessageStreamNode*) senderNode
    andIBeaconMessageActionMapper: (id<BRIBeaconMessageActionMapper>) iBeaconActionMapper
    andRelutionTagMessageActionMapper: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper
    andDistanceEstimator: (id<BRDistanceEstimator>) distanceEstimator;

// Start and stop triggering
- (void) start;
- (void) stop;

// Action execution
- (void) addActionListener: (NSObject<BRBeaconActionListener>*) listener;
- (void) removeActionListener: (NSObject<BRBeaconActionListener>*) listener;
- (void) addActionExecutor: (BRBeaconActionExecutor*) actionExecutor;

// Debugging
- (void) addDebugActionListener: (id<BRBeaconActionDebugListener>) listener;

@end
