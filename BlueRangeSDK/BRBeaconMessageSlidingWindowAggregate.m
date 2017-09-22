//
//  BRBeaconMessageSlidingWindowAggregate.m
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

#import "BRBeaconMessageSlidingWindowAggregate.h"
#import "BRBeaconMessage.h"

@interface BRBeaconMessageSlidingWindowAggregate()

- (BOOL) isOldMessage: (BRBeaconMessage*) message recentMessage: (BRBeaconMessage*) recentMessage;

@end

@implementation BRBeaconMessageSlidingWindowAggregate

- (id) initWithFirstMessage:(BRBeaconMessage *)firstMessage andAggregateDuration:(long)aggregateDurationInMs {
    if (self = [super initWithFirstMessage:firstMessage andAggregateDuration:aggregateDurationInMs]) {
        
    }
    return self;
}

- (void) removeOldMessages {
    BRBeaconMessage* recentMessage = [[self messages] objectAtIndex:[self.messages count]-1];
    for (int i = 0; i < [self.messages count]; i++) {
        BRBeaconMessage* message = [self.messages objectAtIndex:i];
        if ([self isOldMessage:message recentMessage:recentMessage]) {
            [self.messages removeObjectAtIndex:i];
            i--;
        }
    }
}

- (BOOL) isOldMessage: (BRBeaconMessage*) message recentMessage: (BRBeaconMessage*) recentMessage {
    long long messageTimestampInMs = [message.timestamp timeIntervalSince1970] * 1000;
    long long recentMessageTimestampInMs = [recentMessage.timestamp timeIntervalSince1970] * 1000;
    return (recentMessageTimestampInMs - messageTimestampInMs) > [self aggregateDurationInMs];
}

- /* override */ (NSDate*) getStartDate {
    BRBeaconMessage* message = [self.messages objectAtIndex:[self.messages count] - 1];
    long long endDateInMs = [message.timestamp timeIntervalSince1970] * 1000;
    return [NSDate dateWithTimeIntervalSince1970:(endDateInMs - [self aggregateDurationInMs])/1000];
}

- /* override */ (NSDate*) getStopDate {
    BRBeaconMessage* message = [self.messages objectAtIndex:[self.messages count] - 1];
    return message.timestamp;
}

@end
