//
//  BRBeaconMessageScanner.h
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

#import <Foundation/Foundation.h>
#import "BRBeaconMessage.h"
#import "BRBeaconMessageScannerImpl.h"
#import "BRIBeaconMessageScanner.h"

@protocol BRITracer;
@class BRBeaconMessageScannerConfig;
@class BRIBeaconMessageScannerImpl;
@class BRDefaultBeaconMessageScannerImpl;

/**
 * A beacon message scanner can be used to scan beacon messages. Before starting the scanner with
 * the {@link #startScanning} method, you must call the {@link #getConfig} method to get access
 * to the scanner's configuration. By using the configuration, you can specify which messages the
 * scanner should scan for. The {@link #startScanning} and {@link #stopScanning} methods start
 * and stop the scan procedure. If you change properties on the scanner's configuration, after
 * the scanner has been started, the scanner will automatically be restarted. To further process
 * incoming messages, register a {@link BRBeaconMessageStreamNodeReceiver} as a receiver.
 */
@interface BRBeaconMessageScanner : BRIBeaconMessageScanner<BRBeaconMessageScannerImplObserver> {
    // Tracing
    id<BRITracer> _tracer;
    
    // Realization
    NSMutableArray * _impls;
    BRIBeaconMessageScannerImpl * iBeaconScannerImpl;
    BRDefaultBeaconMessageScannerImpl *defaultBeaconScannerImpl;
    
    // Life cycle
    NSThread* _scanCycleThread;
    NSMutableArray* _accumulatedMessagesInCycle;
    NSMutableArray* _messagesToBeSendInCycle;
    BOOL _meshDetected;
    NSTimer *_meshActivityTimer;
}

// Configuration

/**
 The scanner's configuration. The configuration properties can be
 changed even when the scanner is running. However, it should be
 mentioned that each configuration change at runtime will restart
 the scanner!
 */
@property BRBeaconMessageScannerConfig * config;

// State

/**
 True, when the scanner has been started and not stopped yet.
 */
@property BOOL running;


/**
 Creates a new scanner.

 @param tracer The tracer used for logging incoming messages.
 @return The new scanner
 */
- (id) initWithTracer: (id<BRITracer>) tracer;


/**
 Starts the scanner. The scanner will scan for all beacon message types
 as configured in its configuration. It used the CoreBluetooth and
 CoreLocation framework for beacon detection.
 */
- (void) startScanning;


/**
 Stops the scanner.
 */
- (void) stopScanning;

@end
