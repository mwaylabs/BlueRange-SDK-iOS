//
//  BRBeaconTriggerTest.m
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
