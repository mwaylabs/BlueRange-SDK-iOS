//
//  BRBeaconAdvertiser.m
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
