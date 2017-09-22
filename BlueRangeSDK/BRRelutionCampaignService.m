//
//  BRRelutionCampaignService.m
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

#import "BRRelutionCampaignService.h"
#import "BRIBeaconMessageScanner.h"
#import "BRRelutionIBeaconMessageActionMapper.h"
#import "BRIBeaconMessageActionMapperStub.h"
#import "BRRelutionTagMessageActionMapperEmptyStub.h"
#import "BRBeaconMessageActionTrigger.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRBeaconActionListener.h"
#import "BRBeaconActionDebugListener.h"

NSString * const RELUTION_CAMPAIGN_SERVICE_LOG_TAG = @"BRRelutionCampaignService";
const long POLLING_TIME_FOR_REQUESTING_UUID_REGISTRY_IN_MS = 1000L;
const long WAIT_TIME_BETWEEN_UUID_REGISTRY_SYNCHRONIZATION_IN_MS = 10000L; // 10 seconds.

@interface BRRelutionCampaignService()

@end

@implementation BRRelutionCampaignService

- (id) initWithScanner: (BRIBeaconMessageScanner*) scanner andRelution: (BRRelution*) relution {
    if (self = [super init]) {
        self->_scanner = scanner;
        
        //self->_iBeaconMessageActionMapper = [[BRIBeaconMessageActionMapperStub alloc] init];
        self->_iBeaconMessageActionMapper = [[BRRelutionIBeaconMessageActionMapper alloc]
                                             initWithRelution: relution];
        
        self->_relutionTagMessageActionMapper = [[BRRelutionTagMessageActionMapperEmptyStub alloc] init];
        
        self->_trigger = [[BRBeaconMessageActionTrigger alloc] initWithSender:scanner
                                        andIBeaconMessageActionMapper:self->_iBeaconMessageActionMapper
                                        andRelutionTagMessageActionMapper:self->_relutionTagMessageActionMapper];
    }
    return self;
}

- (void) start {
    [self->_trigger start];
}

- (void) stop {
    [self->_trigger stop];
}

- (void) addActionListener: (NSObject<BRBeaconActionListener>*) listener {
    [self->_trigger addActionListener:listener];
}

// Debugging
- (void) addDebugActionListener: (NSObject<BRBeaconActionDebugListener>*) listener {
    [self->_trigger addDebugActionListener:listener];
}

@end
