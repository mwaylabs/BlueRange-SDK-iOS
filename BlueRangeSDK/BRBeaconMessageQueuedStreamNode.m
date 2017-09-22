//
//  BRBeaconMessageQueuedStreamNode.m
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

#import "BRBeaconMessageQueuedStreamNode.h"

const int DEFAULT_MAXIMUM_SIZE = INT_MAX;
const NSTimeInterval QUEUED_STREAM_NODE_SLEEP_TIME = 0.1;

@interface BRBeaconMessageQueuedStreamNode()

- (void) initMessageQueue;
- (void) pushBeaconMessage: (BRBeaconMessage*) beaconMessage;

@end

@implementation BRBeaconMessageQueuedStreamNode

- (id) initWithSender:(BRBeaconMessageStreamNode *)sender {
    if (self = [super initWithSender:sender]) {
        [self initMessageQueue];
    }
    return self;
}

- (id) initWithSenders:(NSArray *)senders {
    if (self = [super initWithSenders:senders]) {
        [self initMessageQueue];
    }
    return self;
}

- (void) initMessageQueue {
    self->_maximumSize = DEFAULT_MAXIMUM_SIZE;
    self->_messageQueue = [[NSMutableArray alloc] init];
}

- /* override */ (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    [self pushBeaconMessage:message];
}

- (void) pushBeaconMessage: (BRBeaconMessage*) beaconMessage {
    // Do not add the message to the list, if the queue is full.
    if ([self->_messageQueue count] >= self.maximumSize) {
        return;
    }
    // Adding the beacon messages is synchronized as it is typical for producer consumer scenarios.
    @synchronized(self->_messageQueue) {
        [self->_messageQueue addObject:beaconMessage];
    }
}

- (BRBeaconMessage*) pullBeaconMessage {
    while ([self->_messageQueue count] == 0) {
        @synchronized(self->_messageQueue) {
            [NSThread sleepForTimeInterval:((double)QUEUED_STREAM_NODE_SLEEP_TIME)];
        }
    }
    @synchronized(self->_messageQueue) {
        BRBeaconMessage* beaconMessage = [self->_messageQueue objectAtIndex:0];
        [self->_messageQueue removeObjectAtIndex:0];
        return beaconMessage;
    }
}

@end
