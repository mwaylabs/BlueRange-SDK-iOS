//
//  BRBeaconMessageAggregator.h
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
#import "BRBeaconMessageAggregate.h"
#import "BRBeaconMessagePacketAggregate.h"
#import "BRBeaconMessageSlidingWindowAggregate.h"

@protocol BRITracer;
@protocol BRMovingAverageFilter;

typedef enum {
    AGGREGATION_MODE_PACKET,
    AGGREGATION_MODE_SLIDING_WINDOW
    
} AggregationMode;

/**
 * A beacon message aggregator is a node in a message processing graph that merges equivalent
 * beacon messages. Whenever the aggregator receives a message from a sender, the message will be
 * added to a matching beacon message aggregate or, if a such an aggregate does not exist, it
 * will be added to a new aggregate instance. Each aggregate has a predefined duration. After
 * this duration all messages contained inside an aggregate will be combined to a new beacon
 * message that is identical to the first message in the aggregate. However to make further
 * message processing more stable, message properties like the RSSI value will be averaged by
 * using a moving average filter. The resulting beacon message will be sent to all receivers of
 * the node.
 */
@interface BRBeaconMessageAggregator : BRBeaconMessageStreamNode<BRBeaconMessagePacketAggregateObserver> {
    // Tracing
    id<BRITracer> _tracer;
    // Aggregates
    NSMutableArray* _aggregates;
    // Garbage Collector
    NSThread* _garbageCollectorThread;
}
// Mode
@property AggregationMode aggregationMode;
// Configuration
@property long aggregateDurationInMs;
// Average filter
@property id<BRMovingAverageFilter> averageFilter;

- (id) initWithTracer: (id<BRITracer>) tracer andSender: (BRBeaconMessageStreamNode*) sender;
- (id) initWithTracer: (id<BRITracer>) tracer andSenders: (NSArray*) senders;
- /* Override */ (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message;
- /* Override */ (void) onAggregateCompleted: (BRBeaconMessagePacketAggregate*) aggregate;
- (void) handleSlidingWindowMessage: (BRBeaconMessageSlidingWindowAggregate*) aggregate;
- (void) stop;

@end
