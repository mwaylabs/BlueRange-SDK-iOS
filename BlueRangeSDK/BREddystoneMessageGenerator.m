//
//  BREddystoneMessageGenerator.m
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

#import "BREddystoneMessageGenerator.h"
#import "BRAbstract.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString* eddystoneServiceID = @"FEAA";
const int EDDY_FRAME_UID = 0b00000000;
const int EDDY_FRAME_URL = 0b00010000;
const int EDDY_FRAME_TLM = 0b00100000;
const int EDDY_FRAME_EID = 0b01000000;

@implementation BREddystoneMessageGenerator

- (BOOL) matches: (NSDictionary*) advertisementData {
    NSData* beaconServiceData = [self getServiceDataForAdvertisementData:advertisementData];
    if (beaconServiceData != nil) {
        return true;
    } else {
        return false;
    }
}

- (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi {
    mustOverride();
}

- (BOOL) isEqual:(id)object {
    mustOverride();
}

- (NSData*) getServiceDataForAdvertisementData: (NSDictionary*) advertisementData {
    NSDictionary *serviceData = advertisementData[CBAdvertisementDataServiceDataKey];
    
    static CBUUID *_singleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _singleton = [CBUUID UUIDWithString:eddystoneServiceID];
    });
    
    NSData *beaconServiceData = serviceData[_singleton];
    return beaconServiceData;
}

@end
