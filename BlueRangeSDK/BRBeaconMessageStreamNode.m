//
//  BRBeaconMessageStreamNode.m
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

#import "BRBeaconMessageStreamNode.h"
#import "BRAbstract.h"

// Private methods
@interface BRBeaconMessageStreamNode()

- (void) initialize;
- (int) indexOfSender: (BRBeaconMessageStreamNode*) sender;

@end

@implementation BRBeaconMessageStreamNode

@synthesize senders;
@synthesize receivers;

// Public
- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (id) initWithSender: (BRBeaconMessageStreamNode *) sender {
    if (self = [super init]) {
        [self initialize];
        [self addSender:sender];
    }
    return self;
}

- (id) initWithSenders: (NSArray *) _senders {
    if (self = [super init]) {
        [self initialize];
        for (int i = 0; i < [_senders count]; i++) {
            BRBeaconMessageStreamNode *sender = [_senders objectAtIndex:i];
            [self addSender:sender];
        }
    }
    return self;
}

- (void) initialize {
    // The senders list should only hold weak references.
    self->senders = [NSPointerArray weakObjectsPointerArray];
    // Receivers, however, strong references
    self->receivers = [[NSMutableArray alloc] init];

}

- (void) addSender: (BRBeaconMessageStreamNode *) sender {
    // Add the this instance as a receiver to the sender.
    [sender addReceiver:self];
    // Add it to the list of senders.
    [self->senders addPointer:(__bridge void * _Nullable)(sender)];
}

- (void) removeSender: (BRBeaconMessageStreamNode *) sender {
    // Remove me from the receiver.
    [sender removeReceiver:self];
    // Remove me from the list of senders
    int index = [self indexOfSender:sender];
    [self->senders removePointerAtIndex:index];
}

- (int) indexOfSender: (BRBeaconMessageStreamNode*) sender {
    for (int i = 0; i < [self->senders count]; i++) {
        BRBeaconMessageStreamNode *currentSender = [senders pointerAtIndex:i];
        if (currentSender == sender) {
            return i;
        }
    }
    return -1;
}

- (void) addReceiver: (id<BRBeaconMessageStreamNodeReceiver>) receiver {
    [self->receivers addObject:receiver];
}

- (void) removeReceiver: (id<BRBeaconMessageStreamNodeReceiver>) receiver {
    [self->receivers removeObject:receiver];
}

// Public abstract
- (void) onMeshActive: (BRBeaconMessageStreamNode *) senderNode {
    // Default implementation is empty.
}

- (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    mustOverride();
}

- (void) onMeshInactive: (BRBeaconMessageStreamNode *) senderNode {
    // Default implementation is empty.
}

@end
