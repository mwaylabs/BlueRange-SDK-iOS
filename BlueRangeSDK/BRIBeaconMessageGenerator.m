//
//  BRIBeaconMessageGenerator.m
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

#import "BRIBeaconMessageGenerator.h"

@implementation BRIBeaconMessageGenerator

- (id) initWithUUID: (NSString*) uuid {
    if (self = [super init]) {
        self->_uuid = [[NSUUID alloc] initWithUUIDString:uuid];
        self->_majorFilteringEnabled = false;
        self->_minorFilteringEnabled = false;
    }
    return self;
}

- (id) initWithUUID: (NSString*) uuid major: (int) major {
    if (self = [super init]) {
        self->_uuid = [[NSUUID alloc] initWithUUIDString:uuid];
        self->_major = major;
        self->_majorFilteringEnabled = true;
        self->_minorFilteringEnabled = false;
    }
    return self;
}

- (id) initWithUUID: (NSString*) uuid major: (int) major minor: (int) minor {
    if (self = [super init]) {
        self->_uuid = [[NSUUID alloc] initWithUUIDString:uuid];
        self->_major = major;
        self->_minor = minor;
        self->_majorFilteringEnabled = true;
        self->_minorFilteringEnabled = true;
    }
    return self;
}

- (BOOL) matches: (CLBeacon*) beacon {
    BOOL isValidBeacon = false;
    
    @try {
        NSUUID *uuid = beacon.proximityUUID;
        int major = [beacon.major intValue];
        int minor = [beacon.minor intValue];
        
        NSUUID *acceptedUuid = self.uuid;
        int acceptedMajor = self->_major;
        int acceptedMinor = self->_minor;
        
        // Check UUID
        isValidBeacon = [uuid isEqual:acceptedUuid];
        
        if (self->_majorFilteringEnabled && (major != acceptedMajor)) {
            isValidBeacon = false;
        }
        
        if (self->_minorFilteringEnabled && (minor != acceptedMinor)) {
            isValidBeacon = false;
        }
    }
    @catch (NSException *exception) {
        isValidBeacon = false;
    }
    
    return isValidBeacon;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BRIBeaconMessageGenerator class]])) {
        return false;
    }
    BRIBeaconMessageGenerator *generator = (BRIBeaconMessageGenerator*)object;
    if (![generator.uuid.UUIDString isEqualToString:self.uuid.UUIDString]) {
        return false;
    }
    
    if ((self->_majorFilteringEnabled && generator->_majorFilteringEnabled) && (generator.major != self.major)) {
        return false;
    }
    
    if ((self->_minorFilteringEnabled && generator->_minorFilteringEnabled) && (generator.minor != self.minor)) {
        return false;
    }
    
    return true;
}

@end
