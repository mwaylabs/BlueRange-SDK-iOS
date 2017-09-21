//
//  BRBeaconMessagePacketAggregate.m
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
