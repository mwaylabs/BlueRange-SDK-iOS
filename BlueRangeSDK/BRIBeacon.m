//
//  BRIBeacon.m
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

#import "BRIBeacon.h"

@implementation BRIBeacon

- (id) initWithUuid: (NSUUID*) uuid andMajor: (int) major andMinor: (int) minor {
    if (self = [super init]) {
        self->_uuid = uuid;
        self->_major = major;
        self->_minor = minor;
    }
    return self;
}

- (NSString *) description {
    NSString *outputString = [NSString stringWithFormat:@"iBeacon: UUID = %@, major = %d, minor = %d",
                              self.uuid.UUIDString, self.major, self.minor];
    return outputString;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BRIBeacon class]])) {
        return false;
    }
    BRIBeacon *iBeacon = (BRIBeacon*)object;
    return [iBeacon.uuid isEqual:self.uuid] &&
        (iBeacon.major == self.major) &&
        (iBeacon.minor == self.minor);
}

- /* override */ (id)copyWithZone:(NSZone *)zone {
    return [[BRIBeacon alloc] initWithUuid:self.uuid andMajor:self.major andMinor:self.minor];
}

@end
