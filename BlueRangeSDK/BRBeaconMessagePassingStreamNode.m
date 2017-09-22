//
//  BRBeaconMessagePassingStreamNode.m
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

#import "BRBeaconMessagePassingStreamNode.h"
#import "BRBeaconMessageStreamNodeReceiver.h"

// Private methods
@interface BRBeaconMessagePassingStreamNode()
- (void) passMessageToReceivers: (BRBeaconMessage*) message;
@end

@implementation BRBeaconMessagePassingStreamNode

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithSender:(BRBeaconMessageStreamNode *)sender {
    if (self = [super initWithSender:sender]) {
        
    }
    return self;
}

- (id) initWithSenders:(NSArray *)senders {
    if (self = [super initWithSenders:senders]) {
        
    }
    return self;
}

// Override
- (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    // 1. Preprocessing
    [self preprocessMessage:message];
    // 2. Delegating
    [self passMessageToReceivers:message];
    // 3. Postprocessing
    [self postprocessMessage:message];
}

- (void) passMessageToReceivers: (BRBeaconMessage*) message {
    for (id<BRBeaconMessageStreamNodeReceiver> receiver in self.receivers) {
        [receiver onReceivedMessage:self withMessage:message];
    }
}

// Protected
/**
 * This method is called right before a beacon message is passed to the receivers.
 * @param message The received message that is going to be passed to the receivers.
 */
- (void) preprocessMessage: (BRBeaconMessage*) message {
    // Default implementation is empty.
}

/**
 * This method is called right after a beacon message was passed to the receivers.
 * @param message The received message that was passed to the receivers.
 */
- (void) postprocessMessage: (BRBeaconMessage*) message {
    // Default implementation is empty.
}

@end
