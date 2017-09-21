//
//  BRBeaconMessageAggregator.h
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
