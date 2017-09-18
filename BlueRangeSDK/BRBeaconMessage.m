//
//  BRBeaconMessage.m
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
