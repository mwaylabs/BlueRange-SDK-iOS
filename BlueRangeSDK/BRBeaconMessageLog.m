//
//  BRBeaconMessageLog.m
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

#import "BRBeaconMessageLog.h"
#import "BRBeaconMessage.h"

NSString * const BEACON_MESSAGE_LOG_TAG = @"BRBeaconMessageLog";

@implementation BRBeaconMessageLog

- (id) initWithMessages: (NSMutableArray*) beaconMessages {
    if (self = [super init]) {
        self->_beaconMessages = beaconMessages;
    }
    return self;
}

- (NSString*) print {
    NSString* result = @"";
    for (BRBeaconMessage* beaconMessage in self->_beaconMessages) {
        result = [NSString stringWithFormat:@"%@%@\n", result, [beaconMessage description]];
    }
    return result;
}

@end
