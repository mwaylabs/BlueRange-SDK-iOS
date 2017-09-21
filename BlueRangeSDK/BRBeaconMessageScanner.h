//
//  BRBeaconMessageScanner.h
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
