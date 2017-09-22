//
//  BREddystoneUrlMessageGenerator.m
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

#import "BREddystoneUrlMessageGenerator.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BREddystoneUrlMessage.h"

@implementation BREddystoneUrlMessageGenerator

- (id) init {
    if (self = [super init]) {
        self->_urlFilteringEnabled = false;
        self->_url = nil;
    }
    return self;
}

- (id) initWithUrl: (NSString*) url {
    if (self = [super init]) {
        self->_urlFilteringEnabled = true;
        self->_url = url;
    }
    return self;
}

- /* override */ (BOOL) matches: (NSDictionary*) advertisementData {
    if (![super matches:advertisementData]) {
        return false;
    }
    @try {
        // Extract manufacturer specific data out of the advertisement data
        NSData* beaconServiceData = [self getServiceDataForAdvertisementData:advertisementData];
        uint8_t* data = (uint8_t*)[beaconServiceData bytes];
        
        // 0. If no manufacturer specific data are available, this is not a valid beacon
        if (beaconServiceData == nil) {
            return false;
        }
        
        // 1. FrameType
        const uint8_t EXPECTED_FRAME_TYPE = EDDY_FRAME_URL;
        uint8_t frameType = data[0];
        if (frameType != EXPECTED_FRAME_TYPE) {
            return false;
        }
        
        // 2. Check namespace
        if (self->_urlFilteringEnabled) {
            NSString* actualUrl = [BREddystoneUrlMessage getUrlStringFromBytes: data withStartByte:2 andLength:17];
            NSString* acceptedUrl = self->_url;
            
            if (![actualUrl isEqualToString:acceptedUrl]) {
                return false;
            }
        }
        
    } @catch (NSException* e) {
        return false;
    }
    
    // In all other cases...
    return true;
}

- /* override */ (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi {
    // Extract manufacturer specific data out of the advertisement data
    NSData* beaconServiceData = [self getServiceDataForAdvertisementData:advertisementData];
    uint8_t* data = (uint8_t*)[beaconServiceData bytes];
    
    // 1. TxPower (we add -41 dBm as specified in the Eddystone specification)
    int txPower = (int)(((int8_t*)([beaconServiceData bytes]))[1]) + -41;
    
    // 2. URL
    NSString* url = [BREddystoneUrlMessage getUrlStringFromBytes:
                     data withStartByte:2 andLength:17];
    
    // Create a new message
    BREddystoneUrlMessage __autoreleasing *message
        = [[BREddystoneUrlMessage alloc] initWithUrl:url andTxPower:txPower andRssi:rssi];
    
    return message;
}

- /* override */ (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BREddystoneUrlMessageGenerator class]])) {
        return false;
    }
    BREddystoneUrlMessageGenerator *generator = (BREddystoneUrlMessageGenerator*)object;
    
    if ((self->_urlFilteringEnabled && generator->_urlFilteringEnabled)
        && (![generator->_url isEqualToString:self->_url])) {
        return false;
    }
    
    return true;
}

@end
