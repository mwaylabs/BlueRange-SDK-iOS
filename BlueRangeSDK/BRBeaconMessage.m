//
//  BRBeaconMessage.m
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

#import "BRBeaconMessage.h"
#import "BRAbstract.h"

// BRConstants
NSString * const BEACON_MESSAGE_TIMESTAMP_KEY = @"timestamp";
NSString* const BEACON_MESSAGE_RSSI_KEY = @"rssi";

// Private methods
@interface BRBeaconMessage()

- (void) initializeWithTimestamp: (NSDate*) timestamp andRssi: (int) rssi;

@end

@implementation BRBeaconMessage

@synthesize timestamp;
@synthesize rssi;

- (id) init {
    return [self initWithTimestamp:[NSDate date] andRssi:-70];
}

- (id) initWithTimestamp: (NSDate*) _timestamp {
    return [self initWithTimestamp:_timestamp andRssi:-70];
}

- (id) initWithTimestamp: (NSDate*) _timestamp andRssi: (int) _rssi {
    if (self = [super init]) {
        [self initializeWithTimestamp: _timestamp andRssi: _rssi];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.timestamp = [coder decodeObjectForKey:BEACON_MESSAGE_TIMESTAMP_KEY];
        self.rssi = [coder decodeIntForKey:BEACON_MESSAGE_RSSI_KEY];
    }
    return self;
}

- (void) initializeWithTimestamp: (NSDate*) _timestamp andRssi: (int) _rssi {
    self.timestamp = _timestamp;
    self.rssi = _rssi;
}

- (NSString*) getType {
    return NSStringFromClass([self class]);
}

- (BOOL) isEqual:(id)object {
    mustOverride();
}

- (NSString *) description {
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:self.timestamp];
    NSString *desc = [self getDescription];
    NSString *str = [NSString stringWithFormat:@"[%@]: %@", dateString, desc];
    return str;
}

- (id) copy {
    BRBeaconMessage *message = [self newCopy];
    message.rssi = self.rssi;
    message.timestamp = self.timestamp;
    return message;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.timestamp forKey:BEACON_MESSAGE_TIMESTAMP_KEY];
    [coder encodeInt:rssi forKey:BEACON_MESSAGE_RSSI_KEY];
}

// Protected

- (NSString *) getDescription {
    mustOverride();
}

- (BRBeaconMessage*) newCopy {
    mustOverride();
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BRBeaconMessage* message = [self copy];
    return message;
}

- /* abstract */ (short) txPower {
    mustOverride();
}

- /* abstract */ (NSUInteger) hash {
    mustOverride();
}

@end
