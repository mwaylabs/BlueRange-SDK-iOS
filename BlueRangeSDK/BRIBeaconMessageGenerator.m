//
//  BRIBeaconMessageGenerator.m
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
