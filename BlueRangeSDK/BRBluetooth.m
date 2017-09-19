//
//  BRBluetooth.m
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
