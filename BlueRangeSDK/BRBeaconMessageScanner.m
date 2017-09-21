//
//  BRBeaconMessageScanner.m
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

#import "BRBeaconMessageScanner.h"
#import "BRConstants.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRBeaconMessageScannerImpl.h"
#import "BRDefaultBeaconMessageScannerImpl.h"
#import "BRIBeaconMessageScannerImpl.h"
#import "BRBeaconMessage.h"
#import "BRBeaconMessageStreamNode.h"
#import "BRTracer.h"
#import "BRIBeaconMessageGenerator.h"
#import "BRRelutionTagMessageGenerator.h"
#import "BRBeaconJoinMeMessageGenerator.h"

NSString * SCANNER_LOG_TAG = @"BRBeaconMessageScanner";
long MESH_INACTIVE_TIMEOUT_IN_MS = 5000L;

@interface BRBeaconMessageScanner()

// Private methods
- (void) onBeaconMessageUpdate: (BRBeaconMessage*) beaconMessage;
- (void) startScanCycle;
- (void) runScanCycle;
- (void) handleMessages: (BRBeaconMessage*) beaconMessage;
- (void) startScannerImpls;
- (void) stopScanCycle;
- (void) stopScannerImpls;
- (void) restartMeshActivityTimer;
- (void) meshInactivityTimeoutReached:(NSTimer *)timer;

@end

@implementation BRBeaconMessageScanner

@synthesize config;
@synthesize running;

- (id) initWithTracer: (id<BRITracer>) tracer {
    if (self = [super init]) {
        // BRTracer
        self->_tracer = tracer;
        
        // Impls
        self->_impls = [[NSMutableArray alloc] init];
        self->iBeaconScannerImpl = [[BRIBeaconMessageScannerImpl alloc] initWithTracer:tracer];
        [self->_impls addObject:iBeaconScannerImpl];
        self->defaultBeaconScannerImpl = [[BRDefaultBeaconMessageScannerImpl alloc] initWithTracer:tracer];
        [self->_impls addObject:defaultBeaconScannerImpl];
        
        // State
        self->_scanCycleThread = nil;
        self->_accumulatedMessagesInCycle = [[NSMutableArray alloc] init];
        self->_messagesToBeSendInCycle = [[NSMutableArray alloc] init];
        self->_meshDetected = false;
        self->_meshActivityTimer = nil;
        self.running = false;
        
        // Init configuration object
        BRBeaconMessageScannerConfig *_config = [[BRBeaconMessageScannerConfig alloc] initWithScanner: self];
        self.config = _config;
    }
    return self;
}

- (void) startScanning {
    @synchronized(self) {
        self->running = true;
        self->_meshDetected = false;
        [self startScanCycle];
        [self startScannerImpls];
        [[BRTracer getInstance] logDebugWithTag:SCANNER_LOG_TAG andMessage:@"Started scanning!"];
    }
}

- (void) startScanCycle {
    self->_scanCycleThread = [[NSThread alloc] initWithTarget:self selector:@selector(runScanCycle) object:nil];
    [self->_scanCycleThread start];
}

- (void) runScanCycle {
    // The second condition is necessary to avoid race conditions occuring, when
    // restarting the scanner. When the scanner is being restarted and the
    // old scan cycle thread has not yet terminated, self.running will be
    // set to true again and thus the old scan cycle thread will not be terminated
    // leading to siginificant performance issues due to the blocks
    // that are synchronized by self->_messagesToBeSendInCycle!
    while ([self running] && ![[NSThread currentThread] isCancelled]) {
        // The accumulated messages will be copied to an array
        // because handling the messages may take a long time.
        // Since this array must be synchronized no messages
        // would be collected anymore. Therefore, we copy the
        // messages to get out of the critical region as soon
        // as possible.
        
        // Measure cycle start time
        NSTimeInterval startTime = CFAbsoluteTimeGetCurrent();
        
        // To avoid deadlocks, we first synchronize on
        // _messagesToBeSendInCycle and then on _accumulatedMessagesInCycle.
        @synchronized (self->_messagesToBeSendInCycle) {
            @synchronized (self->_accumulatedMessagesInCycle) {
                
                // Clear the list of messages to be send.
                [self->_messagesToBeSendInCycle removeAllObjects];
                // Copy and clear the accumulated messages list
                [self->_messagesToBeSendInCycle addObjectsFromArray:self->_accumulatedMessagesInCycle];
                [self->_accumulatedMessagesInCycle removeAllObjects];
            }
        }
        
        @synchronized (self->_messagesToBeSendInCycle) {
            if ([self->_messagesToBeSendInCycle count] > 0) {
                // Send all messages to the scanner's receivers. Duplicates, however, will be ignored.
                for (int i = 0; i < [self->_messagesToBeSendInCycle count]; i++) {
                    BRBeaconMessage* message = [self->_messagesToBeSendInCycle objectAtIndex:i];
                    [self handleMessages:message];
                }
                
                // Clear the list of messages to be send.
                [self->_messagesToBeSendInCycle removeAllObjects];
                
                // Measure cycle end time
                NSTimeInterval endTime = CFAbsoluteTimeGetCurrent();
                float elapsedCycleTimeInSec = endTime - startTime;
                //NSLog(@"Thread: %@, Cycle duration %f", [NSThread currentThread], elapsedCycleTimeInSec*1000);
                float scanPeriodInSec = ((float)self.config.scanPeriodInMs)/1000;
                NSTimeInterval waitTime = scanPeriodInSec - elapsedCycleTimeInSec;
                // Wait until the next scan cycle.
                if (waitTime > 0) {
                    [NSThread sleepForTimeInterval:scanPeriodInSec];
                }
            }
        }
    }
}

- (void) handleMessages: (BRBeaconMessage*) beaconMessage {
    if (!self->_meshDetected) {
        for (id<BRBeaconMessageStreamNodeReceiver> receiver in [self receivers]) {
            [receiver onMeshActive:self];
        }
        self->_meshDetected = true;
    }
    for (id<BRBeaconMessageStreamNodeReceiver> receiver in [self receivers]) {
        if ([BRTracer isEnabled]) {
            NSString *logMessage = [NSString stringWithFormat:@"%@", beaconMessage];
            [[BRTracer getInstance] logDebugWithTag:SCANNER_LOG_TAG andMessage:logMessage];
        }
        [receiver onReceivedMessage:self withMessage:beaconMessage];
    }
    [self restartMeshActivityTimer];
}

- (void) startScannerImpls {
    
    // The BeaconScanner class uses the bridge pattern to separate
    // the public API from its implementation.
    // The implementation is encapsulated in several
    // BeaconScannerImpl objects that scan for different beacon messages
    // in the background. Each implementation object notifies
    // the Beacon Scanner about new incoming beacon messages.
    // All messages flow together in the onUpdateBeaconMessage method
    // and are delivered to the client's BeaconScannerListener
    // on a separate consumer thread.
    
    @synchronized (self.config) {
        // Configure message generators for each implemenation object
        for (BRIBeaconMessageGenerator *generator in [config getIBeaconMessageGenerators]) {
            [iBeaconScannerImpl addMessageGenerator:generator];
        }
        for (id<BRBeaconMessageGenerator> generator in [config getDefaultScannerMessageGenerators]) {
            [defaultBeaconScannerImpl addMessageGenerator:generator];
        }
    }
    
    // Register as observer to get notfied about beacon messages.
    for (id<BRBeaconMessageScannerImpl> impl in self->_impls) {
        [impl setObserver:self];
    }
    
    // Start all internal beacon scanners.
    for (id<BRBeaconMessageScannerImpl> impl in self->_impls) {
        [impl startScanning];
    }
}

- (void) stopScanning {
    // We need to synchronize the start and stop method...
    @synchronized(self) {
        
        // Set the internal state to 'stopped'.
        self->running = false;
        
        // Stop all scanner implementation objects.
        [self stopScannerImpls];
        [self stopScanCycle];
        
        // Stop mesh activity timer
        if (self->_meshActivityTimer != nil) {
            [self->_meshActivityTimer invalidate];
            self->_meshActivityTimer = nil;
        }
        
        [[BRTracer getInstance] logDebugWithTag:SCANNER_LOG_TAG andMessage:@"Stopped scanning!"];
    }
}

- (void) stopScanCycle {
    @synchronized (self->_accumulatedMessagesInCycle) {
        [self->_accumulatedMessagesInCycle removeAllObjects];
    }
    [self->_scanCycleThread cancel];
    self->_scanCycleThread = nil;
}

- (void) stopScannerImpls {
    for (id<BRBeaconMessageScannerImpl> impl in self->_impls) {
        [impl stopScanning];
    }
}

- (void) onBeaconMessageUpdate: (BRBeaconMessage*) beaconMessage {
    // Must be synchronized, because CoreLocation and CoreBluetooth
    // scanner implementation could call this method from different threads.
    // Do not add duplicates to the list of messages each cycle.
    @synchronized (self->_accumulatedMessagesInCycle) {
        if (![self->_accumulatedMessagesInCycle containsObject:beaconMessage]) {
            [self->_accumulatedMessagesInCycle addObject:beaconMessage];
        }
    }
}

- (void) restartMeshActivityTimer {
    // Cancel the running timer if exists
    if (self->_meshActivityTimer != nil) {
        [self->_meshActivityTimer invalidate];
    }
    
    // Start new timer
    self->_meshActivityTimer =
        [NSTimer scheduledTimerWithTimeInterval:(MESH_INACTIVE_TIMEOUT_IN_MS/1000)
                 target:self
                 selector:@selector(meshInactivityTimeoutReached:)
                 userInfo:nil
                 repeats:false];
}

- (void) meshInactivityTimeoutReached:(NSTimer *)timer {
    [[BRTracer getInstance] logDebugWithTag:SCANNER_LOG_TAG andMessage:@"Device has left mesh network or network has become inactive."];
    for (id<BRBeaconMessageStreamNodeReceiver> receiver in [self receivers]) {
        [receiver onMeshInactive:self];
    }
    self->_meshDetected = false;
}

- (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    // Empty implementation since this class is a source node.
}

@end
