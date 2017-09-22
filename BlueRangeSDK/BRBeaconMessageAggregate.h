//
//  BRBeaconMessageAggregate.h
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

@class BRBeaconMessageAggregate;
@class BRBeaconMessage;

/**
 * A beacon message aggregate is a collection of equivalent beacon messages. An aggregate has a
 * predefined lifetime that is specified by a duration. When the end of the lifetime is reached,
 * all observers will be notified about this event.
 */
@interface BRBeaconMessageAggregate : NSObject

@property (readonly) NSMutableArray* messages;
@property (readonly) long aggregateDurationInMs;

- (id) initWithFirstMessage: (BRBeaconMessage*) firstMessage andAggregateDuration: (long) aggregateDurationInMs;
- (void) add: (BRBeaconMessage*) message;
- (BOOL) fits: (BRBeaconMessage*) message;
- (BOOL) isEmpty;
- /* abstract */ (NSDate*) getStartDate;
- /* abstract */ (NSDate*) getStopDate;
- (void) clear;

@end
