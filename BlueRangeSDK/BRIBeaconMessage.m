//
//  BRIBeaconMessage.m
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

#import "BRIBeaconMessage.h"
#import "BRIBeacon.h"

// BRConstants
NSString * const I_BEACON_MESSAGE_UUID_KEY = @"uuid";
NSString * const I_BEACON_MESSAGE_MAJOR_KEY = @"major";
NSString * const I_BEACON_MESSAGE_MINOR_KEY = @"minor";

@implementation BRIBeaconMessage

const short IBEACON_DEFAULT_TXPOWER = -65;

- (id) initWithUUID: (NSUUID*) uuid major:(int) major minor:(int) minor rssi: (int) rssi {
    if (self = [super initWithTimestamp:[NSDate date] andRssi:rssi]) {
        self->_iBeacon = [[BRIBeacon alloc] initWithUuid:uuid andMajor:major andMinor:minor];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        NSUUID* uuid = [coder decodeObjectForKey:I_BEACON_MESSAGE_UUID_KEY];
        int major = [coder decodeIntForKey:I_BEACON_MESSAGE_MAJOR_KEY];
        int minor = [coder decodeIntForKey:I_BEACON_MESSAGE_MINOR_KEY];
        self->_iBeacon = [[BRIBeacon alloc] initWithUuid:uuid andMajor:major andMinor:minor];
    }
    return self;
}

- (NSString *) getDescription {
    return [NSString stringWithFormat:@"%@, rssi = %d, txPower = %d", [self.iBeacon description], self.rssi, [self txPower]];
}

- (BRBeaconMessage*) newCopy {
    BRIBeaconMessage *clonedMessage = [[BRIBeaconMessage alloc]
        initWithUUID:self.uuid major:self.major minor:self.minor rssi:self.rssi];
    return clonedMessage;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BRIBeaconMessage *newMessage = [super copyWithZone:zone];
    newMessage->_iBeacon = [self.iBeacon copyWithZone:zone];
    return newMessage;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BRIBeaconMessage class]])) {
        return false;
    }
    BRIBeaconMessage *message = (BRIBeaconMessage*)object;
    return [message.iBeacon isEqual: self.iBeacon];
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.iBeacon.uuid forKey:I_BEACON_MESSAGE_UUID_KEY];
    [coder encodeInt:self.iBeacon.major forKey:I_BEACON_MESSAGE_MAJOR_KEY];
    [coder encodeInt:self.iBeacon.minor forKey:I_BEACON_MESSAGE_MINOR_KEY];
}

- (NSUUID*) uuid {
    return self.iBeacon.uuid;
}

- (int) major {
    return self.iBeacon.major;
}

- (int) minor {
    return self.iBeacon.minor;
}

- /* Override */ (short) txPower {
    // Unfortunately, the txPower field cannot be determined under iOS devices.
    // Therefore, we use a default value.
    return IBEACON_DEFAULT_TXPOWER;
}

- /* Override */ (NSUInteger) hash {
    return [self.uuid hash] + self.major + self.minor;
}

@end
