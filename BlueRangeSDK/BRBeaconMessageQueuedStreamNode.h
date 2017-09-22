//
//  BRBeaconMessageQueuedStreamNode.h
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
#import "BRBeaconMessageStreamNode.h"

@class BRBeaconMessage;

/**
 * A beacon message queued stream node is a node in a message processing graph that queues all
 * incoming beacon messages. The queue has a maximum size of {@link #maximumSize}. The messages
 * will not be delivered to any receiver. However, they can be pulled by calling the {@link
 * #pullBeaconMessage} method.
 */
@interface BRBeaconMessageQueuedStreamNode : BRBeaconMessageStreamNode {
    NSMutableArray* _messageQueue;
}

@property int maximumSize;

- (id) initWithSender:(BRBeaconMessageStreamNode *)sender;
- (id) initWithSenders:(NSArray *)senders;
- (BRBeaconMessage*) pullBeaconMessage;

- /* override */ (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message;

@end
