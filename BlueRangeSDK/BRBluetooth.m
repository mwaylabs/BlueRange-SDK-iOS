//
//  BRBluetooth.m
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

#import "BRBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>

// Private methods
@interface BRBluetooth()

- (void) handleBluetoothActivationEvent: (BOOL) enabled;
- (void) handleBluetoothSupportEvent: (BOOL) supported;

@end

@implementation BRBluetooth

- (id) init {
    if (self = [super init]) {
        self->_bluetoothActivationListeners = [[NSMutableArray alloc] init];
        self->_bluetoothSupportListeners = [[NSMutableArray alloc] init];
        if(!self.centralManager) {
            self.centralManager = [[CBCentralManager alloc]
                                   initWithDelegate:self queue:dispatch_get_main_queue()];
        }
        [self centralManagerDidUpdateState:self.centralManager];
    }
    return self;
}

- (void) addBluetoothActivationListener: (id<BRBluetoothActivationListener>) listener {
    if (TARGET_OS_SIMULATOR) {
        [listener onBluetoothEnabled:true];
    } else {
        [self->_bluetoothActivationListeners addObject:listener];
    }
}

- (void) addBluetoothSupportListener: (id<BRBluetoothSupportListener>) listener{
    if (TARGET_OS_SIMULATOR) {
        [listener onBluetoothSupported:true];
    } else {
        [self->_bluetoothSupportListeners addObject:listener];
    }
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *stateString = nil;
    switch(self.centralManager.state) {
        case CBCentralManagerStateResetting:
            stateString = @"The connection with the system service was momentarily lost, update imminent.";
            break;
        case CBCentralManagerStateUnsupported:
            [self handleBluetoothSupportEvent: false];
            stateString = @"The platform doesn't support BRBluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            stateString = @"The app is not authorized to use BRBluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            [self handleBluetoothActivationEvent:false];
            stateString = @"BRBluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            [self handleBluetoothSupportEvent: true];
            [self handleBluetoothActivationEvent:true];
            stateString = @"BRBluetooth is currently powered on and available to use.";
            break;
        default:
            stateString = @"State unknown, update imminent.";
            break;
    }
    NSLog(@"BRBluetooth State: %@",stateString);
}

- (void) handleBluetoothActivationEvent: (BOOL) enabled {
    for (id<BRBluetoothActivationListener> listener in self->_bluetoothActivationListeners) {
        [listener onBluetoothEnabled:enabled];
    }
}

- (void) handleBluetoothSupportEvent: (BOOL) supported {
    for (id<BRBluetoothSupportListener> listener in self->_bluetoothSupportListeners) {
        [listener onBluetoothSupported:supported];
    }
}

@end
