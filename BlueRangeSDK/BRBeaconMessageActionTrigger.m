//
//  BRBeaconMessageActionTrigger.m
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

#import "BRTracer.h"
#import "BRAnalyticalDistanceEstimator.h"
#import "BRIBeaconMessageFilter.h"
#import "BRRelutionTagMessageFilter.h"
#import "BRRunningFlag.h"
#import "BRBeaconMessageActionTrigger.h"
#import "BRBeaconMessage.h"
#import "BRBeaconAction.h"
#import "BRBeaconMessageAggregator.h"
#import "BRBeaconMessageQueuedStreamNode.h"
#import "BRBeaconMessageStreamNode.h"
#import "BRBeaconActionRegistry.h"
#import "BRBeaconActionLocker.h"
#import "BRBeaconContentActionExecutor.h"
#import "BRBeaconNotificationExecutor.h"
#import "BRBeaconTagActionExecutor.h"
#import "BRBeaconActionDebugListener.h"

// BRConstants
// Tracing
NSString* const TRIGGER_LOG_TAG = @"BRBeaconMessageActionTrigger";
// Sender nodes
    // Message Queue should not exceed 10 thousand messages.
const int MAXIMUM_QUEUE_SIZE = 10*1024;
// Action registry
const long POLLING_TIME_FOR_CHECKING_REGISTRY_AVAILABILITY_IN_MS = 1000L;
// Action delaying
const long POLLING_TIME_FOR_CHECKING_DELAYED_ACTIONS_IN_MS = 1000L;

// Private methods
@interface BRBeaconMessageActionTrigger()

- (void) initTracer:(id<BRITracer>) tracer;
- (void) initDebugging;
- (void) initSendersWithSenderNode: (BRBeaconMessageStreamNode*) senderNode;
- (void) initMessageProcessing;
- (void) initActionRegistryWithIBeaconMapper:(id<BRIBeaconMessageActionMapper>) iBeaconMessageActionMapper
                         andRelutioTagMapper: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper;
- (void) initActionDistancingWithDistanceEstimator: (id<BRDistanceEstimator>) distanceEstimator;
- (void) initActionDelaying;
- (void) initActionLocking;
- (void) initActionExecution;

- (void) startMessageProcessingThread;
- (void) run: (id) object;
- (void) waitUntilActionRegistryIsAvailableForMessage: (BRBeaconMessage*) message;
- (void) executeActions: (NSMutableArray*) actions;
- (void) notifyDebugListeners: (BRBeaconAction*) action;
- (void) addActionToDelayedActionQueue: (BRBeaconAction*) action;

// Delaying
- (void) startDelayedActionExecutionThread;
- (void) runDelayedActionExecutionThread: (id) object;
- (void) executeElapsedActions;
- (void) waitAWhile;

- (void) stopThread;

@end

@implementation BRBeaconMessageActionTrigger

// Initialization method
- (id) initWithSender: (BRBeaconMessageStreamNode*) senderNode
    andIBeaconMessageActionMapper: (id<BRIBeaconMessageActionMapper>) iBeaconActionMapper
    andRelutionTagMessageActionMapper: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper {
    
    BRAnalyticalDistanceEstimator* distanceEstimator = [[BRAnalyticalDistanceEstimator alloc] init];
    return [self initWithTracer:[BRTracer getInstance] andSender:senderNode andIBeaconMessageActionMapper:iBeaconActionMapper andRelutionTagMessageActionMapper:relutionTagMessageActionMapper andDistanceEstimator:distanceEstimator];
}

- (id) initWithTracer:(id<BRITracer>) tracer andSender: (BRBeaconMessageStreamNode*) senderNode
    andIBeaconMessageActionMapper: (id<BRIBeaconMessageActionMapper>) iBeaconActionMapper
    andRelutionTagMessageActionMapper: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper
    andDistanceEstimator: (id<BRDistanceEstimator>) distanceEstimator {
    
    if (self = [super init]) {
        
        // Initial initialization
        self->_tracer = nil;
        self->_debugModeOn = false;
        self->_debugActionListeners = [[NSMutableArray alloc] init];
        self->_aggregator = nil;
        self->_queueNode = nil;
        self->_runningFlag = nil;
        self->_messageProcessingThread = nil;
        self->_actionRegistry = nil;
        self->_distanceEstimator = nil;
        self->_delayedActions = [[NSMutableArray alloc] init];
        self->_delayedActionExecutionThread = nil;
        self->_actionLocker = nil;
        self->_actionExecutorChain = nil;
        
        // Second initialization
        [self initTracer:tracer];
        [self initDebugging];
        [self initSendersWithSenderNode:senderNode];
        [self initMessageProcessing];
        [self initActionRegistryWithIBeaconMapper:iBeaconActionMapper andRelutioTagMapper:relutionTagMessageActionMapper];
        [self initActionDistancingWithDistanceEstimator:distanceEstimator];
        [self initActionDelaying];
        [self initActionLocking];
        [self initActionExecution];
    }
    return self;
}

- (void) initTracer:(id<BRITracer>) tracer {
    self->_tracer = tracer;
}

- (void) initDebugging {
    
}

- (void) initSendersWithSenderNode: (BRBeaconMessageStreamNode*) senderNode {
    // In order to decouple the sender message processing from the message processing
    // of the trigger, we use a message queue, from which we can pull beacon messages
    // asynchronously. Right before queueing the message, we use a filter to only
    // process iBeacon and Relution tag messages. The stream of iBeacon and Relution
    // tag messages will then be transformed to dense packets of iBeacon and Relution tag
    // messages, so that actions will only be triggered, when the same message is
    // received multiple times in a small amount of time.
    BRIBeaconMessageFilter* iBeaconMessageFilter = [[BRIBeaconMessageFilter alloc] initWithSender:senderNode];
    BRRelutionTagMessageFilter *relutionTagMessageFilter = [[BRRelutionTagMessageFilter alloc] initWithSender:senderNode];
    NSMutableArray *filters = [[NSMutableArray alloc] init];
    [filters addObject:iBeaconMessageFilter];
    [filters addObject:relutionTagMessageFilter];
    self->_aggregator = [[BRBeaconMessageAggregator alloc] initWithTracer:self->_tracer andSenders:filters];
    self->_queueNode = [[BRBeaconMessageQueuedStreamNode alloc] initWithSender:self->_aggregator];
    self->_queueNode.maximumSize = MAXIMUM_QUEUE_SIZE;
    [self addSender:self->_queueNode];
}

- (void) initMessageProcessing {
    self->_runningFlag = [[BRRunningFlag alloc] initWithInitialValue:false];
    self->_messageProcessingThread = nil;
}

- (void) initActionRegistryWithIBeaconMapper: (id<BRIBeaconMessageActionMapper>) iBeaconMessageActionMapper andRelutioTagMapper: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper {
    self->_actionRegistry = [[BRBeaconActionRegistry alloc] initWithTracer:self->_tracer andIBeaconMapper:iBeaconMessageActionMapper andRelutionTagMapper:relutionTagMessageActionMapper];
}

- (void) initActionDistancingWithDistanceEstimator: (id<BRDistanceEstimator>) distanceEstimator {
    self->_distanceEstimator = distanceEstimator;
    [BRBeaconAction setDistanceEstimator:self->_distanceEstimator];
}

- (void) initActionDelaying {
    
}

- (void) initActionLocking {
    self->_actionLocker = [[BRBeaconActionLocker alloc] initWithRunningFlag:self->_runningFlag];
}

- (void) initActionExecution {
    [self addActionExecutor:[[BRBeaconContentActionExecutor alloc] init]];
    [self addActionExecutor:[[BRBeaconNotificationExecutor alloc] init]];
    [self addActionExecutor:[[BRBeaconTagActionExecutor alloc] init]];
}

// Start and stop triggering
- (void) start {
    [self startMessageProcessingThread];
    [self startDelayedActionExecutionThread];
}

- (void) startMessageProcessingThread {
    self->_runningFlag.running = true;
    self->_messageProcessingThread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:nil];
    [self->_messageProcessingThread start];
    [self->_actionLocker start];
}

- (void) run: (id) object {
    while ([self->_runningFlag running] && ![self->_delayedActionExecutionThread isCancelled]) {
        // 1. Pull the next message from the message queue.
        BRBeaconMessage* message = [self->_queueNode pullBeaconMessage];
        @try {
            // 2. Wait until the action registry is available for this message.
            [self waitUntilActionRegistryIsAvailableForMessage:message];
            // 3. Get beacon actions from action registry.
            NSMutableArray* actions = [self->_actionRegistry getBeaconActionsForMessage:message];
            // 4. Execute the actions
            [self executeActions:actions];
        } @catch (BRUnsupportedMessageException* e) {
            // We just skip messages that cannot be mapped to actions.
            [self->_tracer logWarningWithTag:TRIGGER_LOG_TAG
                                  andMessage:@"Skipped action, because message is not supported!"];
        } @catch(BRRegistryNotAvailableException* e) {
            // If the registry is not available the triggering
            // mechanism should not lead to an overflowing message queue.
            // Therefore, we discard these messages.
            [self->_tracer logWarningWithTag:TRIGGER_LOG_TAG
                                  andMessage:@"Skipped action, because registry is currently not available!"];
        } @catch(BRCorruptResponseException* e) {
            // We just skip message that were mapped to corrupt responses
            [self->_tracer logWarningWithTag:TRIGGER_LOG_TAG
                                  andMessage:@"Skipped action, because response is corrupt!"];
        } @catch(NSException* e) {
            // Log the unexpected exception and continue with the next action.
            [self->_tracer logWarningWithTag:TRIGGER_LOG_TAG
                                  andMessage:@"Unexpected exception!"];
        }
    }
}

- (void) waitUntilActionRegistryIsAvailableForMessage: (BRBeaconMessage*) message {
    while(![self->_actionRegistry isAvailable:message] && [self->_runningFlag running]) {
        [NSThread sleepForTimeInterval:((double)POLLING_TIME_FOR_CHECKING_REGISTRY_AVAILABILITY_IN_MS) / 1000];
        [self->_tracer logDebugWithTag:TRIGGER_LOG_TAG
                            andMessage:@"Waiting for action registry to become available."];
    }
}

- (void) executeActions: (NSMutableArray*) actions {
    for (BRBeaconAction* action in actions) {
        // Debug listeners can inspect and supervise the action.
        [self notifyDebugListeners:action];
        // 0. Ignore all actions that are out of range
        if (![action isOutOfRange]) {
            // 1. Ignore all actions whose campaign is not active
            if (![action isCampaignExpired] && ![action isCampaignInactive]) {
                // 2. Ignore all actions that are expired.
                if (![action isExpired]) {
                    // 3. Ignore all actions that are currently locked.
                    if (![self->_actionLocker actionIsCurrentlyLocked:action]) {
                        // 4.1 Lock action if lock is enabled
                        if ([action isLockingAction]) {
                            [self->_actionLocker addActionLock:action];
                        }
                        // 4.2. Check, if action is not delayed.
                        if (![action isDelayed]) {
                            [self->_actionExecutorChain executeAction:action];
                        } else {
                            // If action is delayed, execute it later.
                            [self addActionToDelayedActionQueue:action];
                            NSString* message = [NSString stringWithFormat:@"Added action to delay queue: %@", NSStringFromClass([action class])];
                            [self->_tracer logDebugWithTag:TRIGGER_LOG_TAG andMessage: message];

                        }
                    } else {
                        [self->_actionLocker rememberLock:action];
                        NSString* message = [NSString stringWithFormat:@"Action is locked: %@", NSStringFromClass([action class])];
                        [self->_tracer logDebugWithTag:TRIGGER_LOG_TAG andMessage: message];
                    }
                } else {
                    NSString* message = [NSString stringWithFormat:@"Action is expired: %@", NSStringFromClass([action class])];
                    [self->_tracer logDebugWithTag:TRIGGER_LOG_TAG andMessage: message];
                }
            } else {
                NSString* message = [NSString stringWithFormat:@"Campaign is expired: %@", NSStringFromClass([action class])];
                [self->_tracer logDebugWithTag:TRIGGER_LOG_TAG andMessage: message];
            }
        } else {
            NSString* message1 = [NSString stringWithFormat:@"Action is out of range: %@", NSStringFromClass([action class])];
            [self->_tracer logDebugWithTag:TRIGGER_LOG_TAG andMessage: message1];
            NSString* message2 = [NSString stringWithFormat:@"Distance threshold: %f meters", action.distanceThreshold];
            [self->_tracer logDebugWithTag:TRIGGER_LOG_TAG andMessage: message2];
            NSString* message3 = [NSString stringWithFormat:@"Estimated distance: %f meters", action.distanceEstimationInMetres];
            [self->_tracer logDebugWithTag:TRIGGER_LOG_TAG andMessage: message3];
        }
    }
}

- (void) notifyDebugListeners: (BRBeaconAction*) action {
    for (id<BRBeaconActionDebugListener> listener in self->_debugActionListeners) {
        [listener onActionExecutionStarted:action];
    }
}

- (void) addActionToDelayedActionQueue: (BRBeaconAction*) action {
    @synchronized(self->_delayedActions) {
        [self->_delayedActions addObject:action];
        action.isDelaying = true;
    }
}

- (void) startDelayedActionExecutionThread {
    self->_delayedActionExecutionThread = [[NSThread alloc] initWithTarget:self selector:@selector(runDelayedActionExecutionThread:) object:nil];
    [self->_delayedActionExecutionThread start];
}

- (void) runDelayedActionExecutionThread: (id) object {
    while ([self->_runningFlag running] && ![self->_delayedActionExecutionThread isCancelled]) {
        // 1. Execute elapsed actions.
        [self executeElapsedActions];
        // 2. Wait a while
        [self waitAWhile];
    }
}

- (void) executeElapsedActions {
    // Save modification of delayedActions by synchronizing the threads
    // accessing the list.
    @synchronized(self->_delayedActions) {
        NSMutableArray *removedActions = [[NSMutableArray alloc] init];
        for (BRBeaconAction* delayedAction in self->_delayedActions) {
            // If action is not delayed anymore, we execute the action and
            // remove it from the list.
            if (![delayedAction isDelayed]) {
                // Execute the action.
                [self->_actionExecutorChain executeAction:delayedAction];
                // Remove the action from the list.
                [removedActions addObject:delayedAction];
            }
        }
        [self->_delayedActions removeObjectsInArray:removedActions];
    }
}

- (void) waitAWhile {
    [NSThread sleepForTimeInterval:((double)POLLING_TIME_FOR_CHECKING_DELAYED_ACTIONS_IN_MS) / 1000];
}

- (void) stop {
    [self stopThread];
}

- (void) stopThread {
    [self->_runningFlag setRunning:false];
    [self->_messageProcessingThread cancel];
    [self->_delayedActionExecutionThread cancel];
    [self->_actionLocker cancel];
    if (self->_aggregator != nil) {
        [self->_aggregator stop];
    }
}

// Action execution
- (void) addActionListener: (NSObject<BRBeaconActionListener>*) listener {
    [self->_actionExecutorChain addListener:listener];
}

- (void) removeActionListener: (NSObject<BRBeaconActionListener>*) listener {
    [self->_actionExecutorChain removeListener:listener];
}

- (void) addActionExecutor: (BRBeaconActionExecutor*) actionExecutor {
    if (self->_actionExecutorChain == nil) {
        self->_actionExecutorChain = actionExecutor;
    } else {
        [self->_actionExecutorChain addChainElement:actionExecutor];
    }
}

// Debugging
- (void) addDebugActionListener: (id<BRBeaconActionDebugListener>) listener {
    [self->_debugActionListeners addObject:listener];
}

@end
