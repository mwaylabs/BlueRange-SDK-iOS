//
//  BRRelutionIBeaconMessageActionMapper.m
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

#import "BRRelutionIBeaconMessageActionMapper.h"
#import "BRRelutionActionInformation.h"
#import "BRIBeacon.h"
#import "BRIBeaconMessage.h"
#import "BRTracer.h"
#import "BRJsonUtils.h"
#import "BRBeaconActionRegistry.h"
#import "BRNetwork.h"
#import "BRRelution.h"

// BRConstants
NSString* const IBEACON_ACTION_MAPPER_LOG_TAG = @"BRRelutionIBeaconMessageActionMapper";
NSString* const IBEACON_ACTION_MAPPER_ENDPOINT_URL = @"/campaigns/sdk";

// Private methods
@interface BRRelutionIBeaconMessageActionMapper()

@end

@implementation BRRelutionIBeaconMessageActionMapper

- (id) initWithRelution: (BRRelution*) relution {
    if (self = [super init]) {
        self->_relution = relution;
    }
    return self;
}

- /* override */ (BRRelutionActionInformation*) getBeaconActionInformationForMessage: (BRIBeaconMessage*) message {
    @try {
        BRIBeacon* iBeacon = message.iBeacon;
        BRRelutionActionInformation* actionInformation = [self->_relution getActionsForIBeacon:iBeacon];
        return actionInformation;
    } @catch (NSException* e) {
        @throw [BRRegistryNotAvailableException exceptionWithName:@"" reason:@"" userInfo:nil];
    }
}

- /* override */ (BOOL) isAvailable {
    return [self->_relution isServerAvailable];
}

@end
