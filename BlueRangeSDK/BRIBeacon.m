//
//  BRIBeacon.m
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
