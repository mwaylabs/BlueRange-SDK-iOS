//
//  BRBeaconMessagePacketAggregate.m
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

#import "BRBeaconMessagePacketAggregate.h"
#import "BRBeaconMessage.h"

@interface BRBeaconMessagePacketAggregate()

- (void) initCompletionDate: (BRBeaconMessage*) firstMessage;
- (void) initCompletionTimer;
- (void) onTimerFinished:(NSTimer *)timer;

@end

@implementation BRBeaconMessagePacketAggregate

- (id) initWithFirstMessage: (BRBeaconMessage*) firstMessage andAggregateDuration: (long) aggregateDurationInMs {
    if (self = [super initWithFirstMessage:firstMessage andAggregateDuration:aggregateDurationInMs]) {
        self->_timer = nil;
        self->_observers = [[NSMutableArray alloc] init];
        [self initCompletionDate:firstMessage];
        [self initCompletionTimer];
    }
    return self;
}

- (void) initCompletionDate: (BRBeaconMessage*) firstMessage {
    NSDate *now = [NSDate date];
    NSTimeInterval timeNowInMs = [now timeIntervalSince1970];
    NSTimeInterval creationDateInMs = MIN(timeNowInMs, [firstMessage.timestamp timeIntervalSince1970]);
    // If first message has a lower timestamp than now, use this as the beginning.
    self->_creationDate = [NSDate dateWithTimeIntervalSince1970:creationDateInMs];
    self->_completionDate = [NSDate dateWithTimeIntervalSince1970:(creationDateInMs + ((double)([self aggregateDurationInMs])/1000))];
}

- (void) initCompletionTimer {
    NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(handleCompletionTimer) object:nil];
    [thread start];
}

- (void) handleCompletionTimer {
    NSTimeInterval timeInterval = ([self->_completionDate timeIntervalSince1970] - [self->_creationDate timeIntervalSince1970]);
    [NSThread sleepForTimeInterval:timeInterval];
    [self onTimerFinished:nil];
}

- (void) onTimerFinished:(NSTimer *)timer {
    for (id<BRBeaconMessagePacketAggregateObserver> observer in self->_observers) {
        [observer onAggregateCompleted:self];
    }
}

- (void) addObserver: (id<BRBeaconMessagePacketAggregateObserver>) observer {
    [self->_observers addObject:observer];
}

- /* override */ (NSDate*) getStartDate {
    return [self creationDate];
}

- /* override */ (NSDate*) getStopDate {
    return [self completionDate];
}

- /* override */ (void) clear {
    if (self->_timer != nil) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onTimerFinished:) object:nil];
    }
}

@end
