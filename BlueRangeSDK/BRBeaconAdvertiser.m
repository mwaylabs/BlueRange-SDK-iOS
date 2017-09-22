//
//  BRBeaconAdvertiser.m
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

#import "BRBeaconAdvertiser.h"
#import "BRTracer.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString * LOG_TAG = @"BRBeaconAdvertiser";

@implementation BRBeaconAdvertiser

@synthesize peripheralManager;
@synthesize advertisementData;

- (id) init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void) startAdvertising:(NSDictionary *)_advertisementData;
{
    // Set the advertisementData
    self.advertisementData = _advertisementData;
    // Start advertising
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    // Logging
    [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"BRBeaconAdvertiser started advertising!"];
}

- (void) startAdvertisingDiscoveryMessage
{
    // Construct the advertisement data
    NSMutableArray *services = [[NSMutableArray alloc] init];
    CBUUID *cbUUID = [CBUUID UUIDWithString:@"1234"];
    [services addObject:cbUUID];
    NSDictionary *advertismentData = @{
                                   CBAdvertisementDataLocalNameKey:@"iOS",
                                   CBAdvertisementDataServiceUUIDsKey:services
                                   };
    // Start advertising
    [self startAdvertising:advertismentData];
}

- (void) stopAdvertising
{
    [self.peripheralManager stopAdvertising];
}


// Delegate methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"peripheralStateChange: Powered On"];
            // As soon as the peripheral/bluetooth is turned on, start initializing
            // the service.
            if (peripheral.isAdvertising) {
                [peripheral stopAdvertising];
            }
            [peripheral startAdvertising:self.advertisementData];
            
            break;
        case CBPeripheralManagerStatePoweredOff: {
            [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"peripheralStateChange: Powered Off"];
            break;
        }
        case CBPeripheralManagerStateResetting: {
            [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"peripheralStateChange: Resetting"];
            break;
        }
        case CBPeripheralManagerStateUnauthorized: {
            [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"peripheralStateChange: Deauthorized"];
            break;
        }
        case CBPeripheralManagerStateUnsupported: {
            [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"peripheralStateChange: Unsupported"];
            // TODO: Give user feedback that BRBluetooth is not supported.
            break;
        }
        default:
            [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"peripheralStateChange: Unknown"];
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error != nil) {
        [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"Advertising started with failure"];
    } else {
        [[BRTracer getInstance] logDebugWithTag:LOG_TAG andMessage:@"Advertising started successfully"];
    }
}

@end
