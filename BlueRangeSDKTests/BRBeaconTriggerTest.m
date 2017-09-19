//
//  BRBeaconTriggerTest.m
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

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "BRITracer.h"
#import "BlueRangeSDK.h"
#import "BRTestBlocker.h"
#import "BRDummyTracer.h"

@interface BRBeaconTriggerTest : XCTestCase

@property id<BRITracer> tracer;
@property BRAnalyticalDistanceEstimator* distanceEstimator;
@property BRBeaconMessageScannerSimulator* scanner;
@property BRBeaconTrigger* trigger;
@property id observerMock;
@property BRTestBlocker* testBlocker;

@end

@implementation BRBeaconTriggerTest

- (void)setUp {
    [super setUp];
    
    // Message processing
    self.tracer = [[BRDummyTracer alloc] init];
    self.distanceEstimator = [[BRAnalyticalDistanceEstimator alloc] init];
    self.scanner = [[BRBeaconMessageScannerSimulator alloc] init];
    self.trigger = [[BRBeaconTrigger alloc] initWithTracer:self.tracer andScanner:self.scanner andDistanceEstimator:self.distanceEstimator];
    self.testBlocker = [[BRTestBlocker alloc] init];
    
    // Mode
    [self.trigger setMultiBeaconMode:false];
    
    // Beacons
    [self.trigger addRelutionTagTrigger:1L];
    
    // Reaction
    [self.trigger setReactionMode: PACKET];
    [self.trigger setReactionDurationInMs:0L];
    
    // Ranges
    [self.trigger setActivationDistanceInMeter:2.0];
    [self.trigger setInactivationDurationInMs:3.0];
    
    // Listener
    self.observerMock = OCMProtocolMock(@protocol(BRBeaconTriggerObserver));
    [self.trigger addObserver:self.observerMock];
}

- (void)tearDown {
    [super tearDown];
}

- (void) simulateRelutionTag: (int) tag andDistance: (float) distanceInMeters {
    NSMutableArray* tags = [[NSMutableArray alloc] init];
    [tags addObject:[NSNumber numberWithInt:tag]];
    int rssi = (int)[self.distanceEstimator distanceToRssi:distanceInMeters withA:-55];
    [self.scanner simulateRelutionTagsV1WithRssi:tags andRssi:rssi];
}

@end
