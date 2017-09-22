//
//  BRBeaconMessageAggregator.m
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

#import "BRBeaconMessageAggregator.h"
#import "BRLinearWeightedMovingAverageFilter.h"
#import "BRITracer.h"
#import "BRBeaconMessage.h"
#import "BRBeaconMessageStreamNodeReceiver.h"

NSString* AGGREGATOR_LOG_TAG = @"BRBeaconMessageAggregator";
const long AGGREGATOR_DEFAULT_AGGREGATE_DURATION_IN_MS = 1000;
const float AGGREGATOR_DEFAULT_LINEAR_WEIGHTED_MOVING_AVERAGE_CONSTANT = 0.3;

@interface BRBeaconMessageAggregator()

- (void) initializeWithTracer: (id<BRITracer>) tracer;
- (void) startAggregateGarbageCollector;
- (void) runAggregateGarbageCollector;
- (void) removeGarbage;
- (BRBeaconMessageAggregate*) findAggregateForMessage: (BRBeaconMessage*) message;
- (BRBeaconMessage*) createAggregatedMessage: (BRBeaconMessageAggregate*) aggregate;
- (float) getAverageRssi: (BRBeaconMessageAggregate*) aggregate;
- (void) sendToReceivers: (BRBeaconMessage*) aggregatedMessage;
- (void) removeAggregate: (BRBeaconMessageAggregate*) aggregate;

- (void) publishAggregatedMessageForAggregate: (BRBeaconMessageAggregate*) aggregate;

@end

@implementation BRBeaconMessageAggregator

- (id) initWithTracer: (id<BRITracer>) tracer andSender: (BRBeaconMessageStreamNode*) sender {
    if (self = [super initWithSender:sender]) {
        [self initializeWithTracer:tracer];
    }
    return self;
}

- (id) initWithTracer: (id<BRITracer>) tracer andSenders: (NSArray*) senders {
    if (self = [super initWithSenders:senders]) {
        [self initializeWithTracer:tracer];
    }
    return self;
}

- (void) initializeWithTracer: (id<BRITracer>) tracer {
    self->_tracer = tracer;
    [self setAggregationMode:AGGREGATION_MODE_PACKET];
    self->_aggregateDurationInMs = AGGREGATOR_DEFAULT_AGGREGATE_DURATION_IN_MS;
    self->_aggregates = [[NSMutableArray alloc] init];
    self->_averageFilter = [[BRLinearWeightedMovingAverageFilter alloc] initWithC:AGGREGATOR_DEFAULT_LINEAR_WEIGHTED_MOVING_AVERAGE_CONSTANT];
    self->_garbageCollectorThread = nil;
    
    [self startAggregateGarbageCollector];
}

- (void) startAggregateGarbageCollector {
    self->_garbageCollectorThread = [[NSThread alloc] initWithTarget:self selector:@selector(runAggregateGarbageCollector) object:nil];
    [self->_garbageCollectorThread start];
}

- (void) runAggregateGarbageCollector {
    while (![self->_garbageCollectorThread isCancelled]) {
        [self removeGarbage];
        [NSThread sleepForTimeInterval:10];
    }
}

- (void) removeGarbage {
    @synchronized (self->_aggregates) {
        for (int i = 0; i < [self->_aggregates count]; i++) {
            if (self->_aggregationMode == AGGREGATION_MODE_SLIDING_WINDOW) {
                BRBeaconMessageAggregate* aggregate = [self->_aggregates objectAtIndex:i];
                BRBeaconMessageSlidingWindowAggregate* slidingWindowAggregate = (BRBeaconMessageSlidingWindowAggregate*)aggregate;
                [slidingWindowAggregate removeOldMessages];
                if ([slidingWindowAggregate isEmpty]) {
                    [self->_aggregates removeObject:slidingWindowAggregate];
                }
            }
        }
    }
}

- /* Override */ (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    @synchronized(self->_aggregates) {
        //NSString *logMessage = [NSString stringWithFormat:@"Aggregator received message with RSSI %d", message.rssi];
        //[self->_tracer logDebugWithTag:AGGREGATOR_LOG_TAG andMessage:logMessage];
        BRBeaconMessageAggregate* aggregate = [self findAggregateForMessage: message];
        if (aggregate != nil) {
            [aggregate add:message];
        } else {
            if (self->_aggregationMode == AGGREGATION_MODE_PACKET) {
                BRBeaconMessagePacketAggregate* packetAggregate = [[BRBeaconMessagePacketAggregate alloc] initWithFirstMessage:message andAggregateDuration:_aggregateDurationInMs];
                [packetAggregate addObserver:self];
                [self->_aggregates addObject:packetAggregate];
                aggregate = packetAggregate;
                
            } else if (self->_aggregationMode == AGGREGATION_MODE_SLIDING_WINDOW) {
                BRBeaconMessageSlidingWindowAggregate* slidingWindowAggregate = [[BRBeaconMessageSlidingWindowAggregate alloc] initWithFirstMessage:message andAggregateDuration:_aggregateDurationInMs];
                aggregate = slidingWindowAggregate;
                [self->_aggregates addObject:slidingWindowAggregate];
            }
        }
        
        // Instant reaction in sliding window mode.
        if (self->_aggregationMode == AGGREGATION_MODE_SLIDING_WINDOW) {
            BRBeaconMessageSlidingWindowAggregate* slidingWindowAggregate = (BRBeaconMessageSlidingWindowAggregate*)aggregate;
            [self handleSlidingWindowMessage:slidingWindowAggregate];
        }
    }
}

- (BRBeaconMessageAggregate*) findAggregateForMessage: (BRBeaconMessage*) message {
    for (BRBeaconMessageAggregate *aggregate in self->_aggregates) {
        if ([aggregate fits:message]) {
            return aggregate;
        }
    }
    return nil;
}

- /* Override */ (void) onAggregateCompleted: (BRBeaconMessagePacketAggregate*) aggregate {
    @synchronized(self->_aggregates) {
        [self publishAggregatedMessageForAggregate:aggregate];
        [self removeAggregate:aggregate];
    }
}

- (void) handleSlidingWindowMessage: (BRBeaconMessageSlidingWindowAggregate*) aggregate {
    @synchronized (self->_aggregates) {
        [aggregate removeOldMessages];
        [self publishAggregatedMessageForAggregate:aggregate];
    }
}

- (void) publishAggregatedMessageForAggregate: (BRBeaconMessageAggregate*) aggregate {
    BRBeaconMessage * aggregatedMessage = [self createAggregatedMessage: aggregate];
    [self sendToReceivers:aggregatedMessage];
    NSString *logMessage = [NSString stringWithFormat:@"Sent aggregate message with RSSI %d", aggregatedMessage.rssi];
    [self->_tracer logDebugWithTag:AGGREGATOR_LOG_TAG andMessage:logMessage];
}

- (BRBeaconMessage*) createAggregatedMessage: (BRBeaconMessageAggregate*) aggregate {
    // User first message as prototype.
    BRBeaconMessage * aggregatedMessage = [[aggregate.messages objectAtIndex:0] newCopy];
    // Merge the RSSI value of all messages in this aggregate.
    int avgRssi = (int)[self getAverageRssi:aggregate];
    aggregatedMessage.rssi = avgRssi;
    // Return flattenedMessage
    return aggregatedMessage;
}

- (float) getAverageRssi: (BRBeaconMessageAggregate*) aggregate {
    NSTimeInterval minTime = [[aggregate getStartDate] timeIntervalSince1970];
    NSTimeInterval maxTime = [[aggregate getStopDate] timeIntervalSince1970];
    NSMutableArray *timePoints = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (BRBeaconMessage *message in aggregate.messages) {
        NSTimeInterval time = [message.timestamp timeIntervalSince1970];
        float rssi = (float)message.rssi;
        [timePoints addObject:[NSNumber numberWithDouble:time]];
        [values addObject:[NSNumber numberWithFloat:rssi]];
    }
    
    float average = [self.averageFilter getAverageWithStartTime:minTime andEndTime:maxTime andTimePoints:timePoints andValues:values];
    return average;
}

- (void) sendToReceivers: (BRBeaconMessage*) aggregatedMessage {
    for (id<BRBeaconMessageStreamNodeReceiver> receiver in self.receivers) {
        [receiver onReceivedMessage:self withMessage:aggregatedMessage];
    }
}

- (void) stop {
    @synchronized (self->_aggregates) {
        for (BRBeaconMessageAggregate* aggregate in self->_aggregates) {
            [aggregate clear];
        }
        [self->_aggregates removeAllObjects];
    }
    [self->_garbageCollectorThread cancel];
}

- (void) removeAggregate: (BRBeaconMessageAggregate*) aggregate {
    [aggregate clear];
    [self->_aggregates removeObject:aggregate];
}

@end
