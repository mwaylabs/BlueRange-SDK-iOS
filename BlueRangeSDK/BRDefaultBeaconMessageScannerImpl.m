//
//  BRDefaultBeaconMessageScannerImpl.m
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
