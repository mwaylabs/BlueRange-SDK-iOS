//
//  BRIBeaconMessage.m
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
