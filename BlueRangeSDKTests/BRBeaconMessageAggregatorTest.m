//
//  BRBeaconMessageAggregatorTest.m
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
#import "BRBeaconMessageScannerSimulator.h"
#import "BRBeaconMessageAggregator.h"
#import "BRTestBlocker.h"
#import "BRBeaconMessageStreamNodeReceiver.h"
#import "BRDummyTracer.h"
#import "BRSimpleMovingAverageFilter.h"
#import "BRBeaconMessage.h"

@interface BRBeaconMessageAggregatorTest : XCTestCase

@property id<BRITracer> tracer;
@property BRBeaconMessageScannerSimulator* simulator;
@property BRBeaconMessageAggregator* aggregator;
@property BRTestBlocker* testBlocker;
@property id receiver;

@end

@implementation BRBeaconMessageAggregatorTest

- (void)setUp {
    [super setUp];
    self.tracer = [[BRDummyTracer alloc] init];
    self.simulator = [[BRBeaconMessageScannerSimulator alloc] init];
    
    self.aggregator = [[BRBeaconMessageAggregator alloc] initWithTracer:self.tracer andSender:self.simulator];
    [self.aggregator setAggregateDurationInMs:300];
    self.receiver = OCMProtocolMock(@protocol(BRBeaconMessageStreamNodeReceiver));
    [self.aggregator addReceiver:self.receiver];
    [self.aggregator setAverageFilter:[[BRSimpleMovingAverageFilter alloc] init]];
    
    self.testBlocker = [[BRTestBlocker alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testOneIncomingMessageShouldResultInOneAggregate {
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        XCTAssertEqual(message.rssi, -50);
        return [message isKindOfClass:[BRBeaconMessage class]];
    }]]);
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    OCMVerifyAll(self.receiver);
}

- (void) testTwoEqualMessagesShouldResultInOneAggregate {
    __block int callCount = 0;
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY])._andDo(^(NSInvocation *invocation) {
        ++callCount;
    });
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    XCTAssertEqual(callCount, 1);
}

- (void) testTwoEqualMessagesShouldResultInTwoAggregatesIfAggregateDurationExpired {
    
    [[self.receiver expect] onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY];
    [[self.receiver expect] onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY];
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator startScanning];
    [self.simulator resetSimulatedBeacons];
    [self.testBlocker blockTest:1000];
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    [self.simulator startScanning];
    [self.simulator resetSimulatedBeacons];
    [self.testBlocker blockTest:1000];
    
    [self.receiver verify];
}

- (void) testTwoDifferentMessagesShouldResultInTwoAggregatesEventIfDurationNotExpired {
    [[self.receiver expect] onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY];
    [[self.receiver expect] onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY];
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"c9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    [self.receiver verify];
}

- (void) testRssiAverageInAggregate {
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        XCTAssertEqual(message.rssi, -55);
        return [message isKindOfClass:[BRBeaconMessage class]];
    }]]);
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    OCMVerifyAll(self.receiver);
}

- (void) testSlidingWindowMode {
    [self.receiver setExpectationOrderMatters:YES];
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        XCTAssertEqual(message.rssi, -50);
        return [message isKindOfClass:[BRBeaconMessage class]];
    }]]);
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        XCTAssertEqual(message.rssi, -55);
        return [message isKindOfClass:[BRBeaconMessage class]];
    }]]);
    
    [self.aggregator setAggregationMode:AGGREGATION_MODE_SLIDING_WINDOW];
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    OCMVerifyAll(self.receiver);
}

@end
