//
//  BRDefaultBeaconMessageScannerImpl.m
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

#import "BRDefaultBeaconMessageScannerImpl.h"
#import "BRBeaconMessageScannerImpl.h"
#import "BRRelutionTagMessageGenerator.h"
#import "BRBeaconMessage.h"
#import "BRRelutionTagMessage.h"
#import "BRConstants.h"
#import "BRBeaconMessageGenerator.h"
#import "BRITracer.h"

 // Symbolic constants
NSString * const DEFAULT_SCANNER_LOG_TAG = @"DefaultScanner";

@interface BRDefaultBeaconMessageScannerImpl()

- (BRBeaconMessage*) receivedMeshBeacon: (NSDictionary *)advertisementData rssi:(NSNumber*)RSSI;

@end

@implementation BRDefaultBeaconMessageScannerImpl

- (id) initWithTracer: (id<BRITracer>) tracer {
    if (self = [super init]) {
        self->_tracer = tracer;
        self->_messageGenerators = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addMessageGenerator: (id<BRBeaconMessageGenerator>) messageGenerator {
    @synchronized (self) {
        [self->_messageGenerators addObject:messageGenerator];
    }
}

- (void) setObserver: (id<BRBeaconMessageScannerImplObserver>) observer {
    self->_observer = observer;
}

- (void) startScanning {
    // Scan for all available CoreBluetooth LE devices
    // Duplicate keys must be allowed, otherwise, this method will only return one advertising packet per device once
    self.scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    // Initialize the CBCentralManager
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = centralManager;
    
    [self->_tracer logDebugWithTag:DEFAULT_SCANNER_LOG_TAG andMessage:@"Started scanning!"];
}

// The centralManager must be started first and will then update its state
// This is, when scanning can be started
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        [self->_tracer logDebugWithTag:DEFAULT_SCANNER_LOG_TAG
                            andMessage:@"CoreBluetooth BLE hardware is powered off"];
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        [self->_tracer logDebugWithTag:DEFAULT_SCANNER_LOG_TAG
                            andMessage:@"CoreBluetooth BLE hardware is powered on and ready"];
        
        //Start scanning
        [self.centralManager scanForPeripheralsWithServices:nil options:self.scanOptions];
        //Start timer to respawn scanning from time to time
        self.scanRestartTimer = [NSTimer scheduledTimerWithTimeInterval:kRestartScanTimeIntervalInSec target:self selector:@selector(scanRestartTimerHandler:) userInfo:nil repeats:YES];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        [self->_tracer logDebugWithTag:DEFAULT_SCANNER_LOG_TAG
                            andMessage:@"CoreBluetooth BLE state is unauthorized"];
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        [self->_tracer logDebugWithTag:DEFAULT_SCANNER_LOG_TAG
                            andMessage:@"CoreBluetooth BLE state is unknown"];
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        [self->_tracer logDebugWithTag:DEFAULT_SCANNER_LOG_TAG
                            andMessage:@"CoreBluetooth BLE hardware is unsupported on this platform"];
    } else {
        [self->_tracer logDebugWithTag:DEFAULT_SCANNER_LOG_TAG
                            andMessage:@"CoreBLuetooth reported an unknown state"];
    }
}

//  Restarts scanning every few seconds so that the scanner does not get lazy
- (void)scanRestartTimerHandler:(NSTimer*)timer {
    [self.centralManager scanForPeripheralsWithServices:nil options:self.scanOptions];
}


//Whenever an advertising message is detected, this method is called
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // If the RSSI value could not be determined, we discard this beacon message.
    if ([RSSI intValue] == 127) {
        return;
    }
    
    [self handleBeaconsWithAdvertisementData: advertisementData RSSI: RSSI];
}

- (void) handleBeaconsWithAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    BRBeaconMessage* beaconMessage = nil;
    if ((beaconMessage = [self receivedMeshBeacon: advertisementData rssi: RSSI])) {
        [self->_observer onBeaconMessageUpdate:beaconMessage];
    }
}

- (BRBeaconMessage*) receivedMeshBeacon: (NSDictionary *)advertisementData rssi:(NSNumber*)RSSI {
    id<BRBeaconMessageGenerator> matchingMessageGenerator = nil;
    
    @synchronized (self) {
        for (id<BRBeaconMessageGenerator> messageGenerator in self->_messageGenerators) {
            if ([messageGenerator matches:advertisementData]) {
                matchingMessageGenerator = messageGenerator;
            }
        }
    }
    
    if (matchingMessageGenerator != nil) {
        return [matchingMessageGenerator newMessage: advertisementData withRssi:[RSSI intValue]];
    } else {
        return nil;
    }
}

- (void) stopScanning {
    [self.scanRestartTimer invalidate];
    self.scanRestartTimer = nil;
    
    [self.centralManager stopScan];
    @synchronized (self) {
        [self->_messageGenerators removeAllObjects];
    }
}

@end
