//
//  BRBeaconMessageStreamNode.h
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
#import "BRBeaconMessageStreamNodeReceiver.h"

/**
 * This is the base class of all message processing elements. Each instance of this class can be
 * interpreted as a node in a message stream processing graph, which can receive messages from a
 * list of incoming edges and a can send the messages to all its receivers. By using this class
 * as a base class of all message processing elements, it is possible to combine all elements to a
 * flexible message processing architecture.
 */
@interface BRBeaconMessageStreamNode : NSObject<BRBeaconMessageStreamNodeReceiver>

// Back reference to the receivers
@property (readonly) NSPointerArray* senders;
// Holds all senders
@property (readonly) NSMutableArray* receivers;

// Public
- (id) init;
- (id) initWithSender: (BRBeaconMessageStreamNode *) sender;
- (id) initWithSenders: (NSArray *) senders;
- (void) addSender: (BRBeaconMessageStreamNode *) sender;
- (void) removeSender: (BRBeaconMessageStreamNode *) sender;
- (void) addReceiver: (id<BRBeaconMessageStreamNodeReceiver>) receiver;
- (void) removeReceiver: (id<BRBeaconMessageStreamNodeReceiver>) receiver;

// Public abstract
- /* public abstract */ (void) onMeshActive: (BRBeaconMessageStreamNode *) senderNode;
- /* public abstract */ (void) onMeshInactive: (BRBeaconMessageStreamNode *) senderNode;

@end
